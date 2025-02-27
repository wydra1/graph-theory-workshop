import combinatorics.simple_graph.basic
import data.finite
import data.finset.basic
import data.quot,
import data.order,
import data.set,
universes u

open finset

variables {α : Type u} [decidable_eq α]



variables [fintype α]

/- A matroid M is an ordered pair `(E, ℐ)` consisting of a finite set `E` and
a collection `ℐ` of subsets of `E` having the following three properties:
  (I1) `∅ ∈ ℐ`.
  (I2) If `I ∈ ℐ` and `I' ⊆ I`, then `I' ∈ ℐ`.
  (I3) If `I₁` and `I₂` are in `I` and `|I₁| < |I₂|`, then there is an element `e` of `I₂ − I₁`
    such that `I₁ ∪ {e} ∈ I`.-/

def can_exchange (ℐ : finset α → Prop) : Prop :=
∀ I₁ I₂, ℐ I₁ ∧ ℐ I₂ → finset.card I₁ < finset.card I₂ → ∃ (e ∈ I₂ \ I₁), (ℐ (insert e I₁))

@[ext]
structure matroid (α : Type u) [fintype α] [decidable_eq α] :=
(ℐ : finset α → Prop)
(empty : ℐ ∅) -- (I1)
(hereditary : ∀ (I₁ : finset α), ℐ I₁ → ∀ (I₂ : finset α), I₂ ⊆ I₁ → ℐ I₂) -- (I2)
(ind : can_exchange ℐ) -- (I3)


namespace matroid

variables (M : matroid α) [decidable_pred M.ℐ]

/- A subset of `E` that is not in `ℐ` is called dependent. -/
def dependent_sets : finset (finset α) := filter (λ s, ¬ M.ℐ s) univ.powerset

lemma dep_not_ind (C₁ : finset α): C₁ ∈ M.dependent_sets ↔ ¬M.ℐ C₁ :=
begin
  split,
  {intro h,
  unfold dependent_sets at h,
  have h': C₁ ∈ univ.powerset ∧ ¬ M.ℐ C₁,
  {rw mem_filter at h,
  exact h,},
  cases h',
  contradiction,},
  {intro h,
  unfold dependent_sets,
  rw mem_filter,
  split,
  {simp,},
  {exact h,}}
end

-- (C1)
lemma empty_not_dependent : ∅ ∉ M.dependent_sets :=
begin
  have h: M.ℐ ∅, exact M.empty,
  intro h',
  have h'':¬ M.ℐ ∅,
  {rw <- dep_not_ind,
  exact h',},
  contradiction,
end
variables [decidable_pred (λ (D : finset α), can_exchange (λ (_x : finset α), _x ∈ D.powerset.erase D))]

def circuit : finset (finset α) :=
  finset.filter (λ (D : finset α), (∀ (S ∈ (D.ssubsets)), M.ℐ S)) (M.dependent_sets)


@[simp]
lemma mem_circuit (C₁ : finset α) :
  C₁ ∈ M.circuit ↔ C₁ ∈ M.dependent_sets ∧ (∀ (C ∈ (C₁.ssubsets)), M.ℐ C) :=
begin
  simp,
  split,
  {intro h,
  split, {exact finset.mem_of_mem_filter C₁ h,},
  {intros C g,
  have C₁_dep : C₁∈ M.dependent_sets, exact finset.mem_of_mem_filter C₁ h,
  unfold dependent_sets at C₁_dep,
  rw mem_filter at C₁_dep,
  cases C₁_dep with _ C₁_dep,
  unfold circuit at h,
  have h': C∈ C₁.ssubsets,
  {rw mem_ssubsets,
  exact g,},
  rw mem_filter at h,
  cases h with h₁ h₂,
  specialize h₂ C h',
  exact h₂,}},
  {rintros ⟨h₁, h₂⟩,
  unfold circuit, 
  rw mem_filter,
  split, exact h₁,
  {intros S h',
  have S_sub_C₁ : S ⊂ C₁,
  {rw mem_ssubsets at h',
  exact h',},
  specialize h₂ S S_sub_C₁,
  exact h₂,}}
end

/- `(C2)` if C₁ and C₂ are members of C and C₁ ⊆ C₂, then C₂ = C₂.
In other words, C forms an antichain. -/
lemma circuit_antichain (C₁ C₂ : finset α) (h₁ : C₁ ∈ M.circuit) (h₂ : C₂ ∈ M.circuit) : C₁ ⊆ C₂ → C₁ = C₂ :=
begin
  intro g,
  rw mem_circuit at h₂,
  rw mem_circuit at h₁,
  cases h₁ with C₁_dep h₁,
  cases h₂ with C₂_dep h₂,
  by_contradiction,
  have h' : C₁⊂ C₂, exact ssubset_of_subset_of_ne g h,
  have h'': C₁∈ C₂.ssubsets,
  {rw mem_ssubsets,
  exact h',},
  specialize h₂ C₁ h'',
  rw dep_not_ind at C₁_dep,
  contradiction,
end
/- `(C3)` If C₁ and C₂ are distinct members of M.circuit and e ∈ C₁ ∩ C₂, then
there is a member C₃ of M.circuit such that C₃ ⊆ (C₁ ∪ C₂) - e.   -/
lemma circuit_dependence (C₁ C₂ : finset α) (h₁ : C₁ ∈ M.circuit) (h₂ : C₂ ∈ M.circuit) (h : C₁ ≠ C₂) (e : α) :
  e ∈ C₁ ∩ C₂ → ∃ C₃ ∈ M.circuit, C₃ ⊆ (C₁ ∪ C₂) \ {e} :=
begin
  intro e_in,
  by_contra j,
  push_neg at j,



end


-- for this i think we need a lemma along the lines of, if α is fintype and p : finset α → Prop
-- is a function where ∀ y ⊆ x, p x → p y, then there are "maximal" x : finset α
-- or maybe we can define this w.r.t rank function?
/- A maximal member of `ℐ` is called a basis. -/
def bases : finset (finset α) := filter (λ s, M.ℐ s) univ.powerset


-- this is broken because of some missing instance somewhere, lean doesn't seem to
-- get that if V is finite then a simple graph on V will have finite edge set so
-- uncomment at your own peril (jk if you're feeling up for the challenge you can
-- probably figure out how to fix it)
variables (V : Type u) (G : simple_graph V) [fintype V] [decidable_eq V] [fintype G.edge_set]
namespace simple_graph

instance : fintype G.edge_set :=
{ elems := _,
  complete := _ }

end simple_graph

def graphic_matroid (G : simple_graph V) : matroid G.edge_set := _



-- coercing x from fintype ↑s to fintype α is proving very annoying
@[ext]
def restriction {V : Type u} (M : matroid α) (s : finset α) : matroid s :=
{ ℐ := λ x, M.ℐ _,
  empty := _,
  hereditary := _,
  ind := _ }



end matroid
