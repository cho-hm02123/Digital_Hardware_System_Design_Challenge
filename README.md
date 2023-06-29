# Digital Hardware System Design Challenge

### *Introduction*

The elevator FSM may be designed using Verilog, and the circuit operation may be checked using FPGA. 
For this circuit, state is specified for each floor and floor information is entered through the Pmod pack keypad
It operates by controlling the DC motor and the servo motor according to the layer to be moved (output unit).

### *Operation Process*

An elevator that can move from the first floor to the fourth floor was built.
The elevator's input includes two open buttons and two closed buttons that control the door, and a keypad that allows you to set the floor on which you want to go to the elevator.
This elevator can receive aks keypad input when the open button is pressed, and keypad input is not possible when the closed button is pressed.
If you press the open button, the servo motor operates to open the elevator door, and if you press the close button after setting the floor, the servo motor operates in reverse to close the elevator door, and then operates the DC motor to move to the desired floor.

#### Role

김수민, 김현욱 : Control Algorithm, Pmod Keypad and Segment

이호성 : Main motor control and H/W fabrication
조혜민 : Door motor control and H/W fabrication

##### End.. 
The project was produced for the final project of digital hardware system design by Dankook University's Department of Electronic and Electrical Engineering.
