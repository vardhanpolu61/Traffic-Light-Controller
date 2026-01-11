This project implements a Traffic Light Controller using a Finite State Machine (FSM).
The controller manages traffic flow between a Highway Road and a Country Road based on a vehicle sensor input (X).

The design consists of four states (s0–s3) and controls three traffic light colors (Red, Yellow, Green) for both roads.

FSM State Encoding

The FSM uses 2-bit state encoding:

State	Binary:
s0	00
s1	01
s2	10
s3	11
Traffic Light Color Encoding:
Red	00
Green	01
Yellow	10
Roads:
Highway Road
Country Road

The Highway Road has higher priority by default.

Input Signal:

x (sensor input)

x = 1 → Presence of vehicles on the country road

x = 0 → No vehicles on the country road

State Descriptions & Output Behavior
State	Country Road	Highway Road	Description
s0	Red	Green	Default state, highway has green
s1	Red	Yellow	Transition state (highway prepares to stop)
s2	Green	Red	Country road gets green
s3	Yellow Red	
State Transitions
s0 → s1
Occurs when x = 1 (vehicles detected on country road)
s1 → s2
Highway light transitions from Yellow to Red
A delay of 5 positive clock edges is introduced before switching
s2 → s2
Remains in s2 while x = 1
s2 → s3
Occurs when x = 0
s3 → s0
Returns to default state
Remains in s0 while x = 0
The current state updates only on the positive edge of the clock
A delay of five clock cycles is introduced during the Highway road transition from Yellow to Red to ensure safe signal switching.
Default Behavior

On Clear, the system starts in state s0

Highway road = Green

Country road = Red
