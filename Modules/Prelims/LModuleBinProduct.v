(* The binary product of two modules is a module *)
(*
Direct definition of binary product.
It could also be deduced from LModuleColims.v *)
(* TODO montrer que n'importe quel limite se calcule pointwise *)

(**
[LModule_binproduct]
[LModule_BinProducts] : the cateogyr of modules has products
It is the product of modules
Then it induces a morphism
*)
(* TODO : utiliser PrecategoryBinProduct pour faire M ↦ M x R *)
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.MoreFoundations.Tactics.

Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.whiskering.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.binproducts.
Require Import UniMath.CategoryTheory.Monads.Monads.
Require Import UniMath.CategoryTheory.Monads.LModules.

Local Open Scope cat.
Section ProductModule.
  Context {B:precategory} {R:Monad B}
          {C : precategory}
          (bpC : BinProducts C)
          (hsB : has_homsets B)
          (hsC : has_homsets C)
          ( M N : LModule R C).

  Local Notation bpFunct :=
    (BinProducts_functor_precat B C bpC hsC (M : functor _ _) (N : functor _ _)).

  Definition LModule_binproduct_functor : functor _ _ :=
    BinProductObject  _ bpFunct.
  Local Notation F := LModule_binproduct_functor.
  Local Notation BP := (binproduct_functor bpC).

  (* Is there a lemma that state the existence of a natural transformation
  (A x B) o R --> A o R x B o R  ? *)
  Definition LModule_binproduct_mult_data (x : B) : C ⟦ (R ∙ F) x, F x ⟧.
  Proof.
    cbn.
    apply( fun a a' b b' =>
                 (@functor_on_morphisms _ _ BP (a ,, a') (b ,, b'))).
    split.
    - apply lm_mult.
    - apply lm_mult.
  Defined.
Local Notation σ := (lm_mult _).

  Lemma LModule_binproduct_mult_is_nat_trans : is_nat_trans _ _  LModule_binproduct_mult_data.
  Proof.
    intros x y f.
    cbn.
    etrans; [apply BinProductOfArrows_comp|].
    etrans; [ | eapply pathsinv0; apply BinProductOfArrows_comp].
    apply BinProductOfArrows_eq.
    - apply (nat_trans_ax (σ M)).
    - apply (nat_trans_ax (σ N)).
  Qed.

  Definition LModule_binproduct_mult : R ∙ F ⟹ F :=
    (_ ,, LModule_binproduct_mult_is_nat_trans).
  

  Definition LModule_binproduct_data : LModule_data R C :=
    (F ,, LModule_binproduct_mult).

  Lemma LModule_binproduct_laws : LModule_laws _ LModule_binproduct_data.
  Proof.
    split.
    - intro x.
      cbn.
      etrans; [apply BinProductOfArrows_comp|].
      etrans; [|apply (functor_id BP (M x ,, N x))].
      apply BinProductOfArrows_eq; apply LModule_law1.
    - intro x.
      cbn.
      etrans; [apply BinProductOfArrows_comp|].
      etrans; [ | eapply pathsinv0; apply BinProductOfArrows_comp].
      apply BinProductOfArrows_eq; apply LModule_law2.
  Qed.

  Definition LModule_binproduct : LModule R C := (_ ,, LModule_binproduct_laws).

  Definition LModule_binproductPr1_nt  :   LModule_binproduct ⟹ M
    := BinProductPr1 _ bpFunct.
  Definition LModule_binproductPr2_nt  :   LModule_binproduct ⟹ N
    := BinProductPr2 _ bpFunct.

  Lemma LModule_binproductPr1_laws  : LModule_Mor_laws _ LModule_binproductPr1_nt.
  Proof.
    intro a.
    apply pathsinv0, BinProductOfArrowsPr1.
  Qed.
  Lemma LModule_binproductPr2_laws  : LModule_Mor_laws _ LModule_binproductPr2_nt.
  Proof.
    intro a.
    apply pathsinv0, BinProductOfArrowsPr2.
  Qed.

  Definition LModule_binproductPr1  : LModule_Mor _ LModule_binproduct M :=
    _ ,, LModule_binproductPr1_laws.
  Definition LModule_binproductPr2  : LModule_Mor _ LModule_binproduct N :=
    _ ,, LModule_binproductPr2_laws.

  Local Notation LMOD :=(precategory_LModule R (category_pair _ hsC)).

  Definition LModule_BinProductArrow_laws (S : LModule _ _)
             (f : LModule_Mor _ S M ) (g : LModule_Mor _ S N ) :
    LModule_Mor_laws R (T := S) (T' := LModule_binproduct)
                     (BinProductArrow _ bpFunct (f : nat_trans _ _) (g : nat_trans _ _)).
  Proof.
    intro a.
    cbn.
    etrans;[apply postcompWithBinProductArrow|].
    apply pathsinv0.
    etrans; [apply precompWithBinProductArrow|].
    rewrite (LModule_Mor_σ _ f),(LModule_Mor_σ _ g).
    reflexivity.
  Qed.

  Definition LModule_BinProductArrow (S : LMOD) (f : LMOD ⟦ S, M ⟧)
             (g : LMOD ⟦ S, N ⟧) : LModule_Mor _ S LModule_binproduct  :=
    (_ ,, LModule_BinProductArrow_laws S f g).

  Lemma LModule_BinProductPr1Commutes (S : LMOD) (f : LMOD ⟦ S, M ⟧)
        (g : LMOD ⟦ S, N ⟧) :
    (LModule_BinProductArrow S f g : LMOD ⟦_ , _⟧) · LModule_binproductPr1 = f.
  Proof.
    apply LModule_Mor_equiv; [exact hsC |].
    apply (BinProductPr1Commutes _ _ _ bpFunct).
  Qed.
  Lemma LModule_BinProductPr2Commutes (S : LMOD) (f : LMOD ⟦ S, M ⟧)
        (g : LMOD ⟦ S, N ⟧) :
    (LModule_BinProductArrow S f g : LMOD ⟦_ , _⟧) · LModule_binproductPr2 = g.
  Proof.
    apply LModule_Mor_equiv; [exact hsC |].
    apply (BinProductPr2Commutes _ _ _ bpFunct).
  Qed.

  Lemma LModule_isBinProductCone :
    isBinProduct LMOD _ _ _
                     LModule_binproductPr1 LModule_binproductPr2.
  Proof.
    red.
    intros S f g.
    use unique_exists.
    - exact (LModule_BinProductArrow S f g).
    - split.
      + apply LModule_BinProductPr1Commutes.
      + apply LModule_BinProductPr2Commutes.
    - intro y.
      apply isapropdirprod; apply has_homsets_LModule.
    - intros y [h1 h2].
      apply LModule_Mor_equiv; [exact hsC |].
      apply (BinProductArrowUnique _ _ _ bpFunct).
      +  exact ((LModule_Mor_equiv _ hsC _ _ ) h1).
      +  exact ((LModule_Mor_equiv _ hsC _ _ ) h2).
  Defined.
  Definition LModule_ProductCone : BinProduct LMOD M N  :=
    mk_BinProduct LMOD M N LModule_binproduct
                      LModule_binproductPr1 LModule_binproductPr2
                      LModule_isBinProductCone.

End ProductModule.

Section BinProductsLModule.
  Context {B:precategory} (R:Monad B)
          {C : precategory}
          (bpC : BinProducts C)
          (hsB : has_homsets B)
          (hsC : has_homsets C).
  Local Notation LMOD :=(precategory_LModule R (category_pair _ hsC)).

  Definition LModule_BinProducts : BinProducts LMOD := LModule_ProductCone bpC hsC.
End BinProductsLModule.
