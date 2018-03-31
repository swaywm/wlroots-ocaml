type event = ..

type handler = event -> unit

let handler_pack (state: 'a) (handle: 'event -> 'a -> 'a): handler =
  let st = ref state in
  fun event -> st := (handle event !st)

let handler_nop : handler = fun _ -> ()
let handler_dummy : handler = fun _ -> assert false
