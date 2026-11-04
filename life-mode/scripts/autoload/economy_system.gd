extends Node
## Bank ledger, spend/credit rules, and exactly-once weekly rent.

func can_afford(amount: int) -> bool:
 return amount <= 0 or GameState.money >= amount

func credit(amount: int, reason: String) -> Dictionary:
 if amount <= 0:
  return {"ok": false, "reason": "Invalid credit"}
 var old := GameState.money
 GameState.set_money(old + amount, reason)
 return GameState.add_ledger("credit", amount, reason, GameState.money)

func try_spend(amount: int, reason: String) -> Dictionary:
 if amount < 0:
  return {"ok": false, "reason": "Invalid debit"}
 if amount == 0:
  return {"ok": true, "reason": reason}
 if GameState.money < amount:
  return {"ok": false, "reason": "Not enough funds ($%d needed)" % amount}
 var old := GameState.money
 GameState.set_money(old - amount, reason)
 var entry := GameState.add_ledger("debit", -amount, reason, GameState.money)
 return {"ok": true, "entry": entry}

func repay_arrears(amount: int = -1) -> Dictionary:
 if GameState.rent_arrears <= 0:
  return {"ok": false, "reason": "No rent arrears"}
 var pay := GameState.rent_arrears if amount < 0 else mini(amount, GameState.rent_arrears)
 var spent := try_spend(pay, "Rent arrears repayment")
 if not spent.get("ok", false):
  return spent
 GameState.rent_arrears -= pay
 GameState.append_log("Paid $%d toward rent arrears. Remaining $%d." % [pay, GameState.rent_arrears])
 return {"ok": true, "paid": pay, "arrears": GameState.rent_arrears}

## Process every rent due boundary crossed in (from_minute, to_minute].
func process_rent_between(from_minute: int, to_minute: int) -> Array:
 var charged: Array = []
 if to_minute <= from_minute:
  return charged
 while GameState.rent_next_due_minute <= to_minute:
  var due := GameState.rent_next_due_minute
  if due <= from_minute:
   # Already covered by a previous advance; still bump the schedule pointer if stale.
   GameState.rent_next_due_minute = due + 10080
   continue
  var rent_id := "rent_%d" % due
  if GameState.processed_rent_ids.has(rent_id):
   GameState.rent_next_due_minute = due + 10080
   continue
  var available := GameState.money
  var paid := mini(available, GameState.rent_amount)
  var shortfall := GameState.rent_amount - paid
  if paid > 0:
   GameState.set_money(GameState.money - paid, "Weekly rent")
   GameState.add_ledger("debit", -paid, "Weekly rent", GameState.money)
  if shortfall > 0:
   GameState.rent_arrears += shortfall
   GameState.adjust_need(&"happiness", -5, "Unpaid rent")
   GameState.append_log("Rent due: paid $%d, arrears +$%d (total arrears $%d)." % [paid, shortfall, GameState.rent_arrears])
  else:
   GameState.append_log("Rent paid in full: $%d." % paid)
  GameState.processed_rent_ids.append(rent_id)
  GameState.rent_next_due_minute = due + 10080
  charged.append({"id": rent_id, "paid": paid, "arrears_added": shortfall})
 return charged
