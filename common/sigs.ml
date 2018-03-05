module type Comparable0 = sig
  type t
  val compare : t -> t -> int
  val equal : t -> t -> bool
  val hash : t -> int
end

module type Comparable1 = sig
  type 'a t
  val compare : 'a t -> 'a t -> int
  val equal : 'a t -> 'a t -> bool
  val hash : 'a t -> int
end
