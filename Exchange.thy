theory Exchange imports Event begin

subsection "Question 1"

inductive_set exchange :: "event list set" where
 Nil:  "[] \<in> exchange" |
 Request:  "\<lbrakk>evs1 \<in> exchange\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = A, Receiver = B, Message = Agent A\<rparr> # evs1 \<in> exchange" |
 Response:  "\<lbrakk>evs2 \<in> exchange; Nonce NB \<notin> used evs2;
          \<lparr>Sender = A, Receiver = B, Message = Agent A\<rparr> \<in> set evs2\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = B, Receiver = A, Message =Crypt (pubK A) (Nonce NB)\<rparr> # evs2  \<in>  exchange"

subsection "Question 2"

abbreviation "e1 \<equiv> \<lparr>Sender = Friend 2, Receiver = Friend 8, Message = Agent (Friend 2)\<rparr>"
abbreviation "e2 \<equiv> \<lparr>Sender = Friend 8, Receiver = Friend 2, Message = Crypt (pubK (Friend 2)) (Nonce 5)\<rparr>"

abbreviation "ex1 \<equiv> [e2, e1]"
abbreviation "ex2 \<equiv> [e2, e1, e2, e1]"

lemma e1 : "[e1] \<in> exchange"
proof
  from exchange.Nil show "[] \<in> exchange" by simp
qed

lemma eventList1 : "ex1 \<in> exchange"
proof
  from e1 show "[e1] \<in> exchange" by simp
next
  show "Nonce 5 \<notin> used [e1]" by simp
next
  show "e1 \<in> set [e1]" by simp
qed

subsection "Question 3"

inductive_cases r1 : "e2 # evs \<in> exchange"

lemma "ex2 \<notin> exchange"
proof (rule ccontr)
  assume "\<not> ex2 \<notin> exchange"
  hence "ex2 \<in> exchange" by simp
  thus False
  proof (rule r1)
    assume "Nonce 5 \<notin> used[e1, e2, e1]"
    thus ?thesis by simp
  qed
qed

subsection "Question 4"

theorem spyKnowEnc:
  defines "msg \<equiv> Crypt (pubK (Friend 2)) (Nonce 5)"
  shows "msg \<in> analz (knows ex1)" using msg_def by simp


subsection "Question 5"

theorem spyNotAnalz:
  defines "msg \<equiv> Nonce 5"
  shows "msg \<notin> analz (knows ex1)" using msg_def by auto


subsection "Question 6"

lemma prikey:
  assumes "A \<noteq> Spy"
  shows "evs \<in> exchange \<Longrightarrow> Key (priK A) \<notin> analz (knows evs)"
proof (induction rule: exchange.induct)
  show "Key (priK A) \<notin> analz (knows [])" using assms by simp
next
  fix evs1 A' B 
  assume "Key (priK A) \<notin> analz (knows evs1)"
  thus "Key (priK A) \<notin> analz (knows (\<lparr>Sender = A', Receiver = B, Message = Agent A'\<rparr> # evs1))" by simp
next
  fix evs2 A' B  N
  assume "Key (priK A) \<notin> analz (knows evs2)"
  thus "Key (priK A) \<notin> analz (knows (\<lparr>Sender = B, Receiver = A', Message = Crypt (pubK A') (Nonce N)\<rparr> # evs2))" by simp
qed

subsection "Question 7"

inductive_set exchange_1 :: "event list set" where
 Nil:  "[] \<in> exchange_1" |
 Request:  "\<lbrakk>evs1 \<in> exchange_1\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = A, Receiver = B, Message = Agent A\<rparr> # evs1 \<in> exchange_1" |
 Response:  "\<lbrakk>evs2 \<in> exchange_1; Nonce NB \<notin> used evs2;
          \<lparr>Sender = A, Receiver = B, Message = Agent A\<rparr> \<in> set evs2\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = B, Receiver = A, Message =Crypt (pubK A) (Nonce NB)\<rparr> # evs2  \<in>  exchange_1"|
 Fake:  "\<lbrakk>evsf \<in> exchange_1;  X \<in> synth (analz (knows evsf))\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = Spy, Receiver = B, Message = X\<rparr> # evsf \<in> exchange_1"

subsection "Question 8"

abbreviation "e3 \<equiv> \<lparr>Sender = Friend 2, Receiver = Spy, Message = Agent (Friend 2)\<rparr>"
abbreviation "e4 \<equiv> \<lparr>Sender = Spy, Receiver = Friend 8, Message = Agent (Spy)\<rparr>" 
abbreviation "e5 \<equiv> \<lparr>Sender = Friend 8, Receiver = Spy, Message = Crypt (pubK Spy) (Nonce 5)\<rparr>"

abbreviation "ex3 \<equiv> [e5, e4, e3]"

theorem spyKnowDec:
  defines "msg \<equiv> Nonce 5"
  shows "msg \<in> analz (knows ex3)" using msg_def by simp

lemma e3: "[e3] \<in> exchange_1"
proof
  from exchange_1.Nil show "[] \<in> exchange_1" by simp
qed

lemma e3e4 : "[e4, e3] \<in> exchange_1"
proof
  from e3 show "[e3] \<in> exchange_1" by simp
next
  show "Agent Spy \<in> synth (analz (knows [e3]))" by auto
qed

lemma eventList3 : "ex3 \<in> exchange_1"
proof 
  from e3e4 show "[e4, e3] \<in> exchange_1" by simp
next
  show "Nonce 5 \<notin> used [e4, e3]" by simp
next
  show "e4 \<in> set [e4, e3]" by simp
qed

subsection "Question 9"

inductive_set exchange_2 :: "event list set" where
 Nil:  "[] \<in> exchange_2" |
 Request:  "\<lbrakk>evs1 \<in> exchange_2\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = A, Receiver = B, Message = Crypt (pubK B) (Agent A)\<rparr> # evs1 \<in> exchange_2" |
 Response:  "\<lbrakk>evs2 \<in> exchange_2; Nonce NB \<notin> used evs2;
          \<lparr>Sender = A, Receiver = B, Message = Crypt (pubK B) (Agent A)\<rparr> \<in> set evs2\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = B, Receiver = A, Message =Crypt (pubK A) (Nonce NB)\<rparr> # evs2  \<in>  exchange_2"|
 Fake:  "\<lbrakk>evsf \<in> exchange_2;  X \<in> synth (analz (knows evsf))\<rbrakk>
          \<Longrightarrow> \<lparr>Sender = Spy, Receiver = B, Message = X\<rparr> # evsf \<in> exchange_2"

 
abbreviation "e6 \<equiv> \<lparr>Sender = Friend 2, Receiver = Friend 8, Message = Crypt (pubK (Friend 8)) (Agent (Friend 2))\<rparr>"
abbreviation "e7 \<equiv> \<lparr>Sender = Friend 8, Receiver = Friend 2, Message = Crypt (pubK (Friend 2)) (Nonce 5)\<rparr>"

abbreviation "ex4 \<equiv> [e7, e6]"

lemma e6: "[e6] \<in> exchange_2"
proof
  from exchange_2.Nil show "[] \<in> exchange_2" by simp
qed

lemma eventList4 : "ex4 \<in> exchange_2"
proof
  from e6 show "[e6] \<in> exchange_2" by simp
next
  show "Nonce 5 \<notin> used [e6]" by simp
next
  show "e6 \<in> set [e6]" by simp
qed

theorem spyNotAnalz_2:
  defines "msg \<equiv> Nonce 5"
  shows "msg \<notin> analz (knows ex4)" using msg_def by auto

end