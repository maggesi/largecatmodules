(**
BinProducts of half arities using LModuleBinProduct
(inspired by HArityCoproduct
pullback binproducts
 *)
Require Import UniMath.Foundations.PartD.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.functor_categories.

Require Import UniMath.CategoryTheory.Monads.Monads.
Require Import UniMath.CategoryTheory.Monads.LModules.

Require Import UniMath.CategoryTheory.DisplayedCats.Auxiliary.
Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.

Require Import UniMath.CategoryTheory.limits.binproducts.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.

Require Import Modules.Prelims.lib.
Require Import Modules.Prelims.modules.
Require Import Modules.Prelims.LModuleBinProduct.
Require Import Modules.Arities.aritiesalt.

Section pullback_binprod.
  Context {C : category} {B : precategory}.
  Context {R : Monad B}{S : Monad B} (f : Monad_Mor R S).

  Context {cpC : BinProducts C}.

  Let cpLM (X : Monad B) := LModule_BinProducts   X cpC (homset_property C).
  Let cpFunc := BinProducts_functor_precat  C _ cpC (homset_property C) .

  Context (a b : LModule S C ).

  (* Let αF : O -> functor B C := fun o => α o. *)
  (* Let pbm_α : O -> LModule R C := fun o => pb_LModule f (α o). *)

  Local Notation BPO := (BinProductObject _ ).

  Definition pbm_binprod := pb_LModule f (BPO (cpLM _ a b)).
  Definition binprod_pbm : LModule _ _ := BPO (cpLM _ (pb_LModule f a)(pb_LModule f b)).

  Definition binprod_pbm_to_pbm_binprod_nat_trans : nat_trans binprod_pbm pbm_binprod :=
    nat_trans_id _ .

  Lemma binprod_pbm_to_pbm_binprod_laws : LModule_Mor_laws _ (T := binprod_pbm) (T' := pbm_binprod)
                                                         binprod_pbm_to_pbm_binprod_nat_trans.
  Proof.
    intro c.
    etrans;[apply id_left|].
    apply pathsinv0.
    etrans;[apply id_right|].
    cbn.
    apply pathsinv0.
    apply BinProductOfArrows_comp.
  Qed.
  
  Definition binprod_pbm_to_pbm_binprod : LModule_Mor  _ binprod_pbm pbm_binprod :=
    _ ,, binprod_pbm_to_pbm_binprod_laws.
End pullback_binprod.

Section Binprod.
  Context {C : category} .

  Context {cpC : BinProducts  C}.

  Local Notation hsC := (homset_property C).


  Local Notation HalfArity := (arity C).
  Local Notation MOD R := (precategory_LModule R C).

  Let cpLM (X : Monad C) := LModule_BinProducts   X cpC hsC.
  Let cpFunc := BinProducts_functor_precat  C _ cpC hsC .


  (* Local Notation HARITY := (arity C). *)

  Context (a b : HalfArity).
  Local Notation BPO := (BinProductObject _ ).

  Definition harity_BinProduct_on_objects (R : Monad C) : LModule R C :=
    BPO (cpLM R (a R) (b R)).

  Let ab := harity_BinProduct_on_objects.

  Definition harity_BinProduct_on_morphisms (R S : Monad C)
             (f : Monad_Mor R S) : LModule_Mor _ (ab R)
                                               (pb_LModule f (ab S)).
    eapply (compose (C := (MOD _))); revgoals.
    - cbn.
      apply binprod_pbm_to_pbm_binprod.
    - apply  (BinProductOfArrows _  (cpLM R _ _) (cpLM R _ _)).
      exact ((# a f)%ar).
      exact ((# b f)%ar).
  Defined.

  Definition harity_binProd_data : @arity_data C
    := harity_BinProduct_on_objects ,, harity_BinProduct_on_morphisms.

  Lemma harity_binProd_is_arity : is_arity harity_binProd_data.
  Proof.
    split.
    - intros R c.
      cbn  -[BinProductOfArrows].
      rewrite id_right.
      apply pathsinv0.
      apply BinProductArrowUnique.
      + etrans;[apply id_left|].
        apply pathsinv0.
        etrans;[|apply id_right].
        apply cancel_precomposition.
        apply arity_id.
      + etrans;[apply id_left|].
        apply pathsinv0.
        etrans;[|apply id_right].
        apply cancel_precomposition.
        apply arity_id.
    - intros R S T f g.
      apply LModule_Mor_equiv.
      now apply homset_property.
      apply nat_trans_eq.
      now apply homset_property.
      intro x.
      cbn  -[BinProductOfArrows ].
      repeat  rewrite id_right.
      apply pathsinv0.
      etrans; [apply BinProductOfArrows_comp|].
      apply BinProductOfArrows_eq.
      + assert (h := arity_comp a f g).
        apply LModule_Mor_equiv in h;[|apply homset_property].
        eapply nat_trans_eq_pointwise in h.
        apply pathsinv0.
        etrans;[eapply h|].
        cbn.
        now rewrite id_right.
      + assert (h := arity_comp b f g).
        apply LModule_Mor_equiv in h;[|apply homset_property].
        eapply nat_trans_eq_pointwise in h.
        apply pathsinv0.
        etrans;[eapply h|].
        cbn.
        now rewrite id_right.
  Qed.
      
  Definition harity_binProd : HalfArity := _ ,, harity_binProd_is_arity.

  Lemma harity_binProductPr1_laws : 
    is_arity_Mor harity_binProd a 
                 (fun R => BinProductPr1  _  (cpLM R (a R) (b R)   )).
  Proof.
    intros R S f.
    apply nat_trans_eq;[apply homset_property|].
    intro x.
    cbn -[BinProductPr1 BinProductOfArrows].
    rewrite id_right.
    cbn.
    unfold binproduct_nat_trans_pr1_data.
    set (CC := cpC _ _).
    use (BinProductOfArrowsPr1 _  CC).
  Qed.

  Lemma harity_binProductPr2_laws : 
    is_arity_Mor harity_binProd b 
                 (fun R => BinProductPr2  _  (cpLM R (a R) (b R)   )).
  Proof.
    intros R S f.
    apply nat_trans_eq;[apply homset_property|].
    intro x.
    cbn -[BinProductPr2 BinProductOfArrows].
    rewrite id_right.
    cbn.
    unfold binproduct_nat_trans_pr2_data.
    set (CC := cpC _ _).
    use (BinProductOfArrowsPr2 _  CC).
  Qed.

  Definition harity_binProductPr1 : 
    arity_Mor  harity_binProd a := _ ,, harity_binProductPr1_laws .

  Definition harity_binProductPr2 : 
    arity_Mor  harity_binProd b := _ ,, harity_binProductPr2_laws .

  (* TODO : move to aritiesalt *)
  Definition harity_binProductArrow_laws {c : HalfArity} (ca :  arity_Mor c a )
             (cb : arity_Mor c b)
    :
    is_arity_Mor
      c harity_binProd 
      (fun R => BinProductArrow  _  (cpLM R (a R) (b R)) (ca R) (cb R))  .
  Proof.
    intros R S f.
    apply nat_trans_eq;[apply homset_property|].
    intro x.
    cbn -[BinProductPr1 BinProductPr2 BinProductOfArrows].
    rewrite id_right.
    unfold binproduct_nat_trans_data.
    apply pathsinv0.
    etrans;[apply postcompWithBinProductArrow|].
    apply pathsinv0.
    apply BinProductArrowUnique.
    - cbn.
      etrans.
      {
        rewrite <- assoc.
        apply cancel_precomposition.
        set (CC := cpC _ _).
        apply (BinProductPr1Commutes _ _ _ CC).
      }
      apply arity_Mor_ax_pw.
    - cbn.
      etrans.
      {
        rewrite <- assoc.
        apply cancel_precomposition.
        set (CC := cpC _ _).
        apply (BinProductPr2Commutes _ _ _ CC).
      }
      apply arity_Mor_ax_pw.
  Qed.

  Definition harity_binProductArrow {c : HalfArity} (ca :  arity_Mor c a )
             (cb : arity_Mor c b) : 
    arity_Mor c harity_binProd  := _ ,, harity_binProductArrow_laws ca cb.

  Lemma harity_isBinProduct : isBinProduct arity_precategory   _ _ _
                                           harity_binProductPr1 harity_binProductPr2.
  Proof.
    intros c ca cb.
    use unique_exists.
    - exact (harity_binProductArrow ca cb).
    - split.
      + apply arity_Mor_eq.
        intro R.
        apply (BinProductPr1Commutes  (MOD R) _ _ (cpLM R (a R) (b R))).
      + apply arity_Mor_eq.
        intro R.
        apply (BinProductPr2Commutes  (MOD R) _ _ (cpLM R (a R) (b R))).
    - intro y.
      cbn -[isaprop].
      apply isapropdirprod; apply arity_category_has_homsets.
    - intros y [h1 h2].
      apply arity_Mor_eq.
      intro R.
      apply (BinProductArrowUnique   (MOD R) _ _ (cpLM R (a R) (b R))).
      + now rewrite <- h1.
      + now rewrite <- h2.
  Defined.

  Definition harity_BinProduct : BinProduct arity_precategory a b :=
    mk_BinProduct  _ _ _ _ _ _ harity_isBinProduct.


End Binprod.

Definition harity_BinProducts {C : category}
           (cpC : BinProducts C)
            : BinProducts (arity_precategory (C := C)) :=
   harity_BinProduct (cpC := cpC).