Require Import
  Relation_Definitions Morphisms Ring Program Setoid
  abstract_algebra theory.rings.
Require Export 
  orders.orders orders.maps.

Section contents.
Context `{Ring R} `{!RingOrder o}.
Add Ring R : (stdlib_ring_theory R).

Lemma flip_opp x y : x ≤ y ↔ -y ≤ -x.
Proof.
  assert (∀ a b, a ≤ b → -b ≤ -a).
   intros a b E.
   setoid_replace (-b) with (-a + -b + a) by ring.
   setoid_replace (-a) with (-a + -b + b) at 2 by ring.
   now apply (order_preserving _).
  split; intros; auto.
  rewrite <-(opp_involutive x), <-(opp_involutive y); auto.
Qed.

Lemma flip_opp_strict x y : x < y ↔ -y < -x.
Proof.
  assert (∀ a b, a < b → -b < -a).
   intros a b [E1 E2].
   split.
    now apply ->flip_opp.
   intros E3. apply E2. apply (injective (-)). now symmetry.
  split; intros; auto.
  rewrite <-(opp_involutive x), <-(opp_involutive y); auto.
Qed.

Lemma flip_nonneg_opp x : 0 ≤ x ↔ -x ≤ 0. 
Proof.
  split; intros E.
   rewrite <- opp_0. now apply ->flip_opp.
  apply flip_opp. now rewrite opp_0.
Qed.

Lemma flip_nonpos_opp x : x ≤ 0 ↔ 0 ≤ -x. 
Proof.
  rewrite <-(opp_involutive x) at 1. 
  split; intros; now apply flip_nonneg_opp.
Qed.

Lemma flip_pos_opp x : 0 < x ↔ -x < 0. 
Proof.
  split; intros E.
   rewrite <- opp_0. now apply ->flip_opp_strict.
  apply flip_opp_strict. now rewrite opp_0.
Qed.

Lemma flip_neg_opp x : x < 0 ↔ 0 < -x. 
Proof.
  rewrite <-(opp_involutive x) at 1. 
  split; intros; now apply flip_pos_opp.
Qed.

Lemma flip_nonneg_minus (x y : R) : 0 ≤ y + -x ↔ x ≤ y.
Proof.
  split; intros E.
   setoid_replace x with (x + 0) by ring.
   setoid_replace y with (x + (y + -x)) by ring.
   now apply (order_preserving _).
  rewrite commutativity.
  setoid_replace 0 with (-x + x) by ring.
  now apply (order_preserving _).
Qed.

Lemma flip_nonpos_minus (x y : R) : y + -x ≤ 0 ↔ y ≤ x.
Proof.
  split; intros E.
   apply flip_nonneg_minus, flip_nonneg_opp.
   now rewrite <-opp_swap.
  rewrite opp_swap.
  now apply flip_nonneg_opp, flip_nonneg_minus.
Qed.

Lemma precedes_plus x y : x ≤ y ↔ ∃ z, 0 ≤ z ∧ y = x + z.
Proof.
  split.
   intros E.
   exists (y + - x). split.
    now apply flip_nonneg_minus.
   ring.
  intros [z [Ez1 Ez2]].
  rewrite Ez2, <-(plus_0_r x) at 1.
  now apply (order_preserving (x +)).
Qed.

Global Instance: SemiRingOrder o.
Proof.
  repeat (split; try apply _). 
    apply precedes_plus. 
   apply precedes_plus.
  apply ringorder_mult.
Qed.

Lemma nonpos_mult x y : x ≤ 0 → y ≤ 0 → 0 ≤ x * y.
Proof.
  intros E F.
  setoid_replace (x * y) with (-x * -y) by ring.
  apply ringorder_mult; apply flip_nonpos_opp; assumption.
Qed.

Lemma nonpos_nonneg_mult x y : x ≤ 0 → 0 ≤ y → x * y ≤ 0.
Proof with auto.
  intros E F. 
  apply flip_nonpos_opp. 
  rewrite rings.distr_opp_mult_l. 
  apply ringorder_mult...
  apply flip_nonpos_opp...
Qed.

Lemma nonneg_nonpos_mult x y : 0 ≤ x → y ≤ 0 → x * y ≤ 0.
Proof.
  intros E F.
  rewrite commutativity. 
  now apply nonpos_nonneg_mult.
Qed.

Context `{!TotalOrder o}.

Lemma square_nonneg x : 0 ≤ x * x.
Proof.
  destruct (total_order 0 x).
   now apply ringorder_mult.
  setoid_replace (x * x) with (-x * -x) by ring.
  now apply ringorder_mult; apply flip_nonpos_opp.
Qed.

Lemma eq_opp_self (z : R) : z = -z → z = 0.
Proof.
  intros E.
  apply (antisymmetry (≤)); destruct (total_order 0 z); try easy.
   rewrite E. now apply flip_nonneg_opp.
  rewrite E. now apply flip_nonpos_opp.
Qed.
End contents.

Section another_ring.
  Context `{Ring R} `{!RingOrder o} `{Ring R2} `{o2 : Order R2}.

  Lemma embed_ringorder (f : R2 → R) `{!SemiRing_Morphism f} `{!Injective f} `{!OrderEmbedding f} : 
    RingOrder o2.
  Proof.
    split.
      apply (embed_partialorder f).
     repeat (split; try apply _). intros x y E. 
     apply (order_preserving_back f). rewrite 2!preserves_plus.
     apply ringorder_plus. now apply (order_preserving f).
    intros x E1 y E2. 
    apply (order_preserving_back f). rewrite preserves_mult, preserves_0.
    apply ringorder_mult; rewrite <-(preserves_0 (f:=f)); now apply (order_preserving f).
  Qed.

  Lemma preserving_back_preserves_0 `{!RingOrder o2} {f : R → R2} `{!SemiRing_Morphism f} : 
    (∀ x, 0 ≤ f x → 0 ≤ x) → OrderPreservingBack f.
  Proof.
    intros E.
    repeat (split; try apply _).
    intros x y F.
    apply flip_nonneg_minus. apply E.
    rewrite preserves_plus, preserves_opp.
    apply flip_nonneg_minus. apply F.
  Qed.
End another_ring.