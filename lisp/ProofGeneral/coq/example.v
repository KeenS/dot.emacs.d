(*
    Example proof script for Coq Proof General.

    example.v,v 11.1 2013/05/14 19:28:22 tews Exp
*)

Module Example.

  Lemma and_commutative : forall (A B:Prop),(A /\ B) -> (B /\ A).
  Proof.
    intros A B H.
    destruct H.
    split.
      trivial.
    trivial.
  Qed.

End Example.
