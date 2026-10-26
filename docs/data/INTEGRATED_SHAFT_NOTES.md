# v1.10 integrated double-eccentric input shaft

The one-piece machined shaft combines the motor-shaft coupling socket, concentric core, and both eccentric journals. Journal A and Journal B are machined at equal and opposite radial offsets, fixing their phase at 180 degrees.

## Assembly constraint

The rear cycloid/bearing cannot pass over the front eccentric journal. It therefore installs from the coupling end before the rear plate and motor spacer. The coupling hub OD must be smaller than the rear bearing ID (or direct-contact cycloid bore at simplified levels). The OpenSCAD model asserts this assembly passage.

## Machining

A practical process is to rough from bar stock sized for the maximum eccentric envelope, machine the motor socket and concentric features, then finish the two eccentric journals using offset centers, an eccentric fixture, or turn-mill/4-axis equipment. Bearing journal tolerances and surface finish should follow the selected bearing manufacturer's fit guidance.

## Torque coupling

The socket/set-screw coupling remains application-specific. Motor shaft flats/keys, screw engagement, fretting, fatigue, and transmitted torque have not been rated by this model.
