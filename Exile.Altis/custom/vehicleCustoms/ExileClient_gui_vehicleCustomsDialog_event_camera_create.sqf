disableSerialization;


ExileClientVehicleCustomsCamPosition = getPos player;
ExileClientVehicleCustomsCamPosition = [(ExileClientVehicleCustomsCamPosition select 0) + 1.25,(ExileClientVehicleCustomsCamPosition select 1) + 1.25,(ExileClientVehicleCustomsCamPosition select 2) + 1.25];

ExileClientVehicleCustomsCam = "camera" camCreate ExileClientVehicleCustomsCamPosition;
ExileClientVehicleCustomsCam cameraEffect ["internal", "back"];
showcinemaBorder false;
ExileClientVehicleCustomsCam camSetPos ExileClientVehicleCustomsCamPosition;
ExileClientVehicleCustomsCam camPrepareTarget (getPos player);
ExileClientVehicleCustomsCam camPrepareFOV 0.75;
ExileClientVehicleCustomsCam camCommitPrepared 0.5;


//ExileClientVehicleCustomsCam camCommitPrepared 0.5;
//waitUntil {camCommitted ExileClientVehicleCustomsCam};


