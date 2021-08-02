open Ctypes

module type Size = sig
  type t
  val zero : t
  val logor : t -> t -> t
  val logand : t -> t -> t
end

module type Elems = sig
  type t
  module Size : Size
  val size : Size.t typ
  val desc : (t * Size.t) list
end

module type Enum = sig
  type elem
  type t
  val t : t
end

module Make (E : Elems) : Enum = struct
  type elem = E.t
  type t = E.t list typ
  let t : t =
    let read i =
      List.filter_map (fun (x, cst) ->
          if (E.Size.logand i cst) <> E.Size.zero then
            Some x
          else None
        ) E.desc
    in
    let write items =
      List.fold_left (fun i item ->
          E.Size.logor (List.assoc item E.desc) i
        ) E.Size.zero items
    in
    view ~read ~write E.size
end
