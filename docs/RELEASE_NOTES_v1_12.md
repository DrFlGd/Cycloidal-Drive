# v1.12

Input shaft support release. See the README section "What changed in v1.12" for the user-facing summary.

## Front pilot bearing
- `input_front_support` (Auto / Pilot bearing / None), `front_pilot_bearing_select` (Auto, 625ZZ ... 6806VV, Custom), `front_pilot_journal_extra`.
- The one-piece sleeve or the integrated coupled shaft extends forward into a bearing pocketed in the rear face of the output hub ring and retained by the inner race retainer. Auto selection descends from the largest catalog size that clears the hub clamp screws and passes the output centre bore.
- Printed builds (levels 2-3) use a plain journal in the hub bore with the print clearances.
- Auto selection also requires the front eccentric bearing (or the disc bore at levels 2-3) to pass over the concentric pilot during assembly (journal <= bore - 2 x eccentricity) and 0.8 mm of wall around the sleeve's shaft bore; both are asserted for explicit selections too. The set-screw collar OD obeys the same passage rule.
- Catalog additions: 607ZZ, 6802VV, 6803VV, 6804VV, 6805VV, 6806VV.

## Rear support bearing
- `coupled_rear_support` (Auto / Bearing in spacer / None), `rear_support_bearing_select`, custom dimensions.
- Available for the machined coupled shaft with separate sleeves: a bearing on the coupling hub inside the motor spacer, inserted from the motor side against a shoulder 1 mm behind the gearbox face.
- Presets: NEMA23 `coupled_hub_od_setting` 16 -> 17 mm (6803VV), NEMA34 24 -> 25 mm (6805VV).

## Stack fix
- `output_hub_z = race_backer_z + race_retainer_t`; hub thickness = output bearing width. Previously the hub ring and the inner race retainer occupied the same axial space.

## Assertions
- Pilot pocket clears the hub clamp screws; pilot journal passes the output centre bore; set-screw collar clears the pilot bearing; rear support bearing bore equals the hub OD; coupling hub reaches the rear bearing; spacer wall around the rear bearing pocket; coupled shaft and sleeve journal extents.

## Views, export, tooling
- Assembly, exploded, input_stack and layout_3d draw the new bearings; `output_hub_ring` 3D solid carries the pilot pocket; `motor_standoff_plate` 3D solid carries the rear bearing bore.
- `tools/validate_presets.py` records the selected front and rear support bearings per combination; the validation CSV (now `docs/data/validation_matrix.csv`).
