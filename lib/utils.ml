open Ctypes

include Wlroots_bindings.Bindings.Utils

let ptr_hash : 'a ptr -> int = fun p ->
  to_voidp p |> raw_address_of_ptr |> Hashtbl.hash

let mk_equal compare x y = compare x y = 0

module Ptr = struct
  let compare = ptr_compare
  let hash = ptr_hash
  let equal = ptr_eq
end

module O = struct
  type 'a data =
    | Owned of 'a
    | Transfered_to_C of unit ptr (* GC root *)

  type 'a t = { mutable box : 'a data }

  let compare cmp x1 x2 =
    match (x1.box, x2.box) with
    | Owned o1, Owned o2 -> cmp o1 o2
    | Transfered_to_C p1, Transfered_to_C p2 -> ptr_compare p1 p2
    | Owned _, Transfered_to_C _ -> -1
    | Transfered_to_C _, Owned _ -> 1

  let hash h x =
    match x.box with
    | Owned o -> h o
    | Transfered_to_C p -> ptr_hash p

  let create : 'a -> 'a t = fun data ->
    { box = Owned data }

  let transfer_ownership_to_c : 'a t -> unit = function
    | { box = Owned data } as t ->
      let root = Root.create data in
      t.box <- Transfered_to_C root
    | { box = Transfered_to_C _ } ->
      failwith "transfer_ownership: data not owned"

  let reclaim_ownership : 'a t -> 'a = function
    | { box = Transfered_to_C root } as t ->
      let data = Root.get root in
      Root.release root;
      t.box <- Owned data;
      data
    | { box = Owned _ } ->
      failwith "reclaim_ownership: data not transfered to C"

  let state : 'a t -> [`owned | `transfered_to_c] = function
    | { box = Owned _ } -> `owned
    | { box = Transfered_to_C _ } -> `transfered_to_c
end
