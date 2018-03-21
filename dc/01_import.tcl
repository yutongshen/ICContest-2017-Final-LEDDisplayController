set_svf LEDDC.svf

# Import Design
read_verilog {../src/LEDDC.v ../src/DataReceiver.v ../src/PWMConvert.v}
current_design [get_designs LEDDC]
link

source -echo -verbose ./LEDDC_DC.sdc
