using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;

public class VehicleControl : MonoBehaviour
{

    public Material[] aiCarBodyMat;
    public MeshRenderer carBodyMesh;

    public GameObject plakePlayer;
    public GameObject plakeAI;
    public GameObject carAllEffectGO;
    public bool raceCarActive;
    public string carName;
    public int carId;
    public CarSettings carSettingsData;
    public Transform startTargetTR;
    public Transform finalPosTR;

    public TurboCharger turboCharger;
    public SuperCharger superCharger;
    // Wheels Setting /////////////////////////////////

    public CarWheels carWheels;
    public float torqueFactor = 1f;

    [System.Serializable]
    public class CarWheels
    {
        public ConnectWheel wheels;
        public WheelSetting setting;
    }


    [System.Serializable]
    public class ConnectWheel
    {
        public bool frontWheelDrive = true;
        public Transform frontRight;
        public Transform frontLeft;

        public bool backWheelDrive = true;
        public Transform backRight;
        public Transform backLeft;
    }

    [System.Serializable]
    public class WheelSetting
    {
        public float Radius = 0.4f;
        public float Weight = 1000.0f;
        public float Distance = 0.2f;
        public float forwardFrictionFront = 1f;
        public float sidewayFrictionFront = 1f;

        public float forwardFrictionBack = 1f;
        public float sidewayFrictionBack = 1f;
        public float forceAppPointDistance = 0.2f;
    }


    // Lights Setting ////////////////////////////////

    public CarLights carLights;

    [System.Serializable]
    public class CarLights
    {
        public Light[] brakeLights;
        public Light[] reverseLights;

        public GameObject[] brakeLights_decal;

    }

    // Car sounds /////////////////////////////////

    public CarSounds carSounds;

    [System.Serializable]
    public class CarSounds
    {
        public AudioSource turboOn;
        public AudioSource turboOff;


        public AudioSource nitro;
        public AudioSource nitroDeep;
        public AudioSource switchGear;
    }

    // Car Particle /////////////////////////////////

    public CarParticles carParticles;

    [System.Serializable]
    public class CarParticles
    {
        public Material brakeParticleMaterial;
        public GameObject brakeParticlePerfab;
        public ParticleSystem shiftParticle1, shiftParticle2;
        private GameObject[] wheelParticle = new GameObject[4];
        public ParticleSystem afterBurn;
        public GameObject lightingPAritcleGO;
        public GameObject finalLightingParitcleGO;
        public GameObject[] brakeParticles;
        public GameObject rainParticle;
    }

    // Car Engine Setting /////////////////////////////////

    public CarSetting carSetting;

    [System.Serializable]
    public class CarSetting
    {
        public float gearShiftSpeed;
        public bool showNormalGizmos = false;
        public Transform carSteer;
        public HitGround[] hitGround;

        public float springs = 25000.0f;
        public float dampers = 1500.0f;

        public float carPower = 120f;
        public float nosPower = 150f;
        public float brakePower = 20000f;



        public Vector3 shiftCentre = new Vector3(0.0f, -0.8f, 0.0f);

        public float maxSteerAngle = 25.0f;

        public float shiftDownRPM = 1500.0f;
        public float shiftUpRPM = 2500.0f;
        public float idleRPM = 500.0f;
        public float maxRPM = 7000.0f;

        public float stiffness = 2.0f;


        public bool automaticGear = true;

        public float[] gears = { -10f, 9f, 6f, 4.5f, 3f, 2.5f };
        public float gearFactor = 1f;

        public float LimitBackwardSpeed = 60.0f;
        public float LimitForwardSpeed = 220.0f;

    }


    [System.Serializable]
    public class HitGround
    {

        public string tag = "street";
        public bool grounded = false;
        public AudioClip brakeSound;
        public AudioClip groundSound;
        public Color brakeColor;
    }


    // Camera Setting ///////////////////////////////////////////////////////////////

    public CameraView cameraView;


    [System.Serializable]
    public class CameraView
    {
        public List<Transform> cameraSwitchView;

        public float distance = 8.0f;
        public float height = 2.5f;
        public float angle = 8;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public float accel = 0.0f;
    public float steer = 0;


    public bool brake;


    public bool shifmotor;
    private float torque = 100f;

    [HideInInspector]
    public float curTorque = 100f;

    public float powerShiftMax = 100f;
    public float powerShift = 100;
    public float nosTime;
    float nosCounter = 0f;
    public bool shift;
    public bool shifting = false;


    public float speed = 0.0f;

    private float lastSpeed = -10.0f;

    [SerializeField] private float[] efficiencyTable;


    private float Pitch;
    private float PitchDelay;

    private float shiftTime = 0.0f;

    private float shiftDelay = 0.0f;



    public int currentGear = 0;

    public bool neutralGear = true;

    public float motorRPM = 0.0f;

    [HideInInspector]
    public bool Backward = false;

    ////////////////////////////////////////////// TouchMode (Control) ////////////////////////////////////////////////////////////////////

    [HideInInspector]
    public float accelFwd = 0.0f;
    [HideInInspector]
    public float accelBack = 0.0f;
    [HideInInspector]
    public float steerAmount = 0.0f;


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private float wantedRPM = 0.0f;
    private float w_rotate;
    private float slip, slip2 = 0.0f;
    private float slipRate = 1.0f;

    public GameObject[] Particle = new GameObject[4];

    private Vector3 steerCurAngle;

    public Rigidbody myRigidbody;
    public Slider _slider;
    public bool gearShiftingAcitve = false;
    FloatingJoystick floatingJoystick;
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public WheelComponent[] wheels;

    public class WheelComponent
    {

        public Transform wheel;
        public WheelCollider collider;
        public Vector3 startPos;
        public float rotation = 0.0f;
        public float rotation2 = 0.0f;
        public float maxSteer;
        public bool drive;
        public float pos_y = 0.0f;
    }
    public RealisticEngineSound realisticEngineSound;

    private WheelComponent SetWheelComponent(Transform wheel, float maxSteer, bool drive, float pos_y)
    {


        WheelComponent result = new WheelComponent();
        GameObject wheelCol = new GameObject(wheel.name + "WheelCollider");

        wheelCol.transform.parent = transform;
        wheelCol.transform.position = wheel.position;
        wheelCol.transform.eulerAngles = transform.eulerAngles;
        pos_y = wheelCol.transform.localPosition.y;

        WheelCollider col = (WheelCollider)wheelCol.AddComponent(typeof(WheelCollider));

        result.wheel = wheel;
        result.collider = wheelCol.GetComponent<WheelCollider>();
        result.drive = drive;
        result.pos_y = pos_y;
        result.maxSteer = maxSteer;
        result.startPos = wheelCol.transform.localPosition;

        return result;

    }
    //public int difficultySelect = 0;
    public int randomEngineLevel = 0;
    public int randomBodyLevel = 0;
    public int randomWheelLevel = 0;
    public int randomGearboxLevel = 0;
    public int randomNosLevel = 0;

    public float usingNosTime = 0;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Exhaust exhaust;
    void Awake()
    {
        neutralGear = true;
        //realisticEngineSound = transform.GetComponent<RealisticEngineSound>();

        //AIVehicle = transform.GetComponent<AIVehicle>();

        if (carParticles.brakeParticleMaterial)
            carParticles.brakeParticlePerfab.GetComponent<ParticleSystemRenderer>().material = carParticles.brakeParticleMaterial;


        foreach(var exh in GetComponentsInChildren<Exhaust>())
        {
            exhaust = exh;
        }
        //myRigidbody = transform.GetComponent<Rigidbody>();
    }
    private void Start()
    {
        DnzEvents.RaceStart += StartRace;
        CarInit();
        raceCarActive = true;
        CameraManager.Instance.carCamera.m_Follow = transform;
        CameraManager.Instance.carCamera.m_LookAt = transform;
        ControlManager.Instance.playerCar = this;
        GameUI.Instance.vehicleControl = this;
        floatingJoystick = GameUI.Instance.floatingJoystick;
    }
    public void StartRace()
    {
        neutralGear = false;
        accel = 1;
    }
    public void CarInit()
    {

        AllUpgradeValueInit();

        EngineUpgradeOtherValue();
        BodyUpgradeOtherValue();
        TiresUpgradeOtherValue();
        TransmissionUpgradeOtherValue();

        NosUpgrade();
    }
    void AIBrakeTypeInitRandom()
    {

    }
    private void OnDestroy()
    {
    }
  
    //public void StartCar()
    //{
    //    StartCoroutine(StartCar_Delay());


    //}
    //IEnumerator StartCar_Delay()
    //{
    //    yield return new WaitForSeconds(0.1f);

    //    CarInit();



    //    raceCarActive = true;
    //}
    void AllUpgradeValueInit()
    {

            carSetting.carPower = carSettingsData.engineUpgrade[0].power;


            myRigidbody.mass = carSettingsData.bodyUpgrade[0].weight;


            carWheels.setting.forwardFrictionFront = carSettingsData.tiresUpgrade[0].tireFriction;
            carWheels.setting.forwardFrictionBack = carSettingsData.tiresUpgrade[0].tireFriction;


            carSetting.gearShiftSpeed = carSettingsData.transmissionUpgrade[0].shiftTime;

    }
    void EngineUpgradeOtherValue()
    {

            myRigidbody.mass += carSettingsData.engineUpgrade[0].weight;

            carWheels.setting.forwardFrictionFront += carSettingsData.engineUpgrade[0].tireFriction;
            carWheels.setting.forwardFrictionBack += carSettingsData.engineUpgrade[0].tireFriction;

            carSetting.gearShiftSpeed += carSettingsData.engineUpgrade[0].shiftTime;

    }


    void BodyUpgradeOtherValue()
    {

            carSetting.carPower += carSettingsData.bodyUpgrade[0].power;

            carWheels.setting.forwardFrictionFront += carSettingsData.bodyUpgrade[0].tireFriction;
            carWheels.setting.forwardFrictionBack += carSettingsData.bodyUpgrade[0].tireFriction;

            carSetting.gearShiftSpeed += carSettingsData.bodyUpgrade[0].shiftTime;

    }


    void TiresUpgradeOtherValue()
    {

            carSetting.carPower += carSettingsData.tiresUpgrade[0].power;

            myRigidbody.mass += carSettingsData.tiresUpgrade[0].weight;

            carSetting.gearShiftSpeed += carSettingsData.tiresUpgrade[0].shiftTime;




        wheels = new WheelComponent[4];

        wheels[0] = SetWheelComponent(carWheels.wheels.frontRight, carSetting.maxSteerAngle, carWheels.wheels.frontWheelDrive, carWheels.wheels.frontRight.position.y);
        wheels[1] = SetWheelComponent(carWheels.wheels.frontLeft, carSetting.maxSteerAngle, carWheels.wheels.frontWheelDrive, carWheels.wheels.frontLeft.position.y);

        wheels[2] = SetWheelComponent(carWheels.wheels.backRight, 0, carWheels.wheels.backWheelDrive, carWheels.wheels.backRight.position.y);
        wheels[3] = SetWheelComponent(carWheels.wheels.backLeft, 0, carWheels.wheels.backWheelDrive, carWheels.wheels.backLeft.position.y);


        WheelInit();
    }
    void TransmissionUpgradeOtherValue()
    {

            carSetting.carPower += carSettingsData.transmissionUpgrade[0].power;


            myRigidbody.mass += carSettingsData.transmissionUpgrade[0].weight;


            carWheels.setting.forwardFrictionFront += carSettingsData.transmissionUpgrade[0].tireFriction;
            carWheels.setting.forwardFrictionBack += carSettingsData.transmissionUpgrade[0].tireFriction;



    }
    void NosUpgrade()
    {
        carSetting.nosPower = carSetting.carPower * (1 + carSettingsData.nosUpgrade[0].nosPowerRatio);
        nosTime = carSettingsData.nosUpgrade[0].nosCapacity;
        carSetting.nosPower = carSetting.carPower * (1 + carSettingsData.nosUpgrade[2].nosPowerRatio);
        nosTime = carSettingsData.nosUpgrade[2].nosCapacity;
        powerShift = powerShiftMax;
    }
    public void FrontSuspensionUp()
    {
        for (int i = 0; i < 2; i++)
        {


            WheelCollider col = wheels[i].collider;
            col.suspensionDistance = carSetting.carPower / 1200f;
        }
        StartCoroutine(SuspensionDelay());
    }
    IEnumerator SuspensionDelay()
    {
        yield return new WaitForSeconds(2f);
        FrontSuspensionDown();
    }
    public void FrontSuspensionDown()
    {
        for (int i = 0; i < wheels.Length; i++)
        {


            WheelCollider col = wheels[i].collider;
            col.suspensionDistance = carWheels.setting.Distance;
        }
    }
    public void WheelInit()
    {

        if (carSetting.carSteer)
            steerCurAngle = carSetting.carSteer.localEulerAngles;

        //foreach (WheelComponent w in wheels)
        for (int i = 0; i < wheels.Length; i++)
        {


            WheelCollider col = wheels[i].collider;
            col.suspensionDistance = carWheels.setting.Distance;
            JointSpring js = col.suspensionSpring;

            js.spring = carSetting.springs;
            js.damper = carSetting.dampers;

            col.suspensionSpring = js;
            col.radius = carWheels.setting.Radius;
            col.mass = carWheels.setting.Weight;
            col.forceAppPointDistance = carWheels.setting.forceAppPointDistance;
            WheelFrictionCurve fc = col.forwardFriction;

            fc.asymptoteValue = 5000.0f;
            fc.extremumSlip = 2.0f;
            fc.asymptoteSlip = 20.0f;
            fc.stiffness = carSetting.stiffness;
            if (i == 0 || i == 1)
            {
                fc.extremumValue = carWheels.setting.forwardFrictionFront;
            }
            if (i == 2 || i == 3)
            {
                fc.extremumValue = carWheels.setting.forwardFrictionBack;
            }
            col.forwardFriction = fc;


            fc = col.sidewaysFriction;
            //fc.extremumValue = carWheels.setting.sidewayFrictionFront;
            if (i == 0 || i == 1)
            {
                fc.extremumValue = carWheels.setting.sidewayFrictionFront;
            }
            if (i == 2 || i == 3)
            {
                fc.extremumValue = carWheels.setting.sidewayFrictionBack;
            }
            fc.asymptoteValue = 7500.0f;
            fc.asymptoteSlip = 2.0f;
            fc.stiffness = carSetting.stiffness;
            col.sidewaysFriction = fc;

        }
    }
    public Transform cameraFollowPosTR;
    public Transform cameraLookTR;
    float totalDistance;
    float currentDistance = 0;
    public bool arrivedFinish = false;
    void SliderSet()
    {
        if (!arrivedFinish)
        {
            currentDistance = Vector3.Distance(transform.position, finalPosTR.position);
            _slider.value = 1f - (currentDistance / totalDistance);
        }
        else
        {
            _slider.value = 1f;
        }
    }



    private void LateUpdate()
    {
        if(exhaust != null)
        {
            exhaust.ExhaustGas(motorRPM);
        }
    }


    int shiftingTrue = 0;

    public void ShiftUp()
    {

        float now = Time.timeSinceLevelLoad;

        if (now < shiftDelay) return;

        if (currentGear < carSetting.gears.Length - 1)
        {

            // if (!carSounds.switchGear.isPlaying)
            carSounds.switchGear.GetComponent<AudioSource>().Play();



            if (!carSetting.automaticGear)
            {
                if (currentGear == 0)
                {
                    if (neutralGear) { currentGear++; neutralGear = false; }
                    else
                    { neutralGear = true; }
                }
                else
                {
                    currentGear++;
                }
            }
            else
            {
                currentGear++;
            }

            shiftDelay = now + 0.5f;
            shiftTime = 1.5f;
        }
        if (motorRPM > 5000)
        {
            carSounds.turboOff.Play();
        }
 
        carParticles.afterBurn.Play();

        StartCoroutine(GearShifting());

    }


    public void ShiftDown()
    {
        float now = Time.timeSinceLevelLoad;

        if (now < shiftDelay) return;

        if (currentGear > 1 || neutralGear)
        {

            //w if (!carSounds.switchGear.isPlaying)
            carSounds.switchGear.GetComponent<AudioSource>().Play();

            if (!carSetting.automaticGear)
            {
                if (currentGear == 1)
                {
                    if (!neutralGear) { currentGear--; neutralGear = true; }
                }
                else if (currentGear == 0) { neutralGear = false; } else { currentGear--; }
            }
            else
            {
                currentGear--;
            }
           if( currentGear < 1)
            {
                currentGear = 1;
            }
            shiftDelay = now + 0.1f;
            shiftTime = 2.0f;
        }

        StartCoroutine(GearShifting());
    }



    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    void Update()
    {
        if (raceCarActive)
        {

            if (!carSetting.automaticGear)
            {
                if (Input.GetKeyDown(KeyCode.K))
                    ShiftUp();
                if (Input.GetKeyDown(KeyCode.L))
                    ShiftDown();
            }



            if (shift && (currentGear > 1 && speed > 50.0f) && shifmotor)
            {

                if (powerShift == 0)
                {
                    shifmotor = false;
                    //carParticles.lightingPAritcleGO.SetActive(false);
                    FrontSuspensionDown();
                }
                nosCounter += Time.deltaTime;
                powerShift = Mathf.Lerp(powerShiftMax, 0.0f, nosCounter / nosTime);

             
                carSounds.nitro.volume = Mathf.Lerp(0.2f, 1.0f, nosCounter / 2);
                carSounds.nitroDeep.volume = Mathf.Lerp(0.2f, 1.0f, nosCounter / 2);

                if (!carSounds.nitro.isPlaying)
                {
                    carSounds.nitro.GetComponent<AudioSource>().Play();
                    carSounds.nitroDeep.GetComponent<AudioSource>().Play();

                }

                shifting = true;
                curTorque = powerShift > 0 ? carSetting.nosPower / slipRate : carSetting.carPower / slipRate;

                carParticles.shiftParticle1.gameObject.SetActive(true);
                carParticles.shiftParticle2.gameObject.SetActive(true);

                //carParticles.shiftParticle1.emissionRate = Mathf.Lerp(carParticles.shiftParticle1.emissionRate, powerShift > 0 ? 50 : 0, Time.deltaTime * 10.0f);
                //carParticles.shiftParticle2.emissionRate = Mathf.Lerp(carParticles.shiftParticle2.emissionRate, powerShift > 0 ? 50 : 0, Time.deltaTime * 10.0f);
            }
            else
            {

                if (powerShift > 20) shifmotor = true;

                carSounds.nitro.volume = Mathf.MoveTowards(carSounds.nitro.volume, 0.0f, Time.deltaTime * 2.0f);
                carSounds.nitroDeep.volume = Mathf.MoveTowards(carSounds.nitroDeep.volume, 0.0f, Time.deltaTime * 2.0f);

                if (carSounds.nitro.volume == 0)
                {
                    carSounds.nitro.Stop();
                    carSounds.nitroDeep.Stop();
                }

                shifting = false;
                //powerShift = Mathf.MoveTowards(powerShift, powerShiftMax, Time.deltaTime * 5.0f);
                //if (vehicleMode == VehicleMode.Player)
                //{
                //    GameUI.Instance.panels.gamePlay.nosFill.fillAmount = powerShift / powerShiftMax;
                //}
                curTorque = carSetting.carPower / slipRate;

                carParticles.shiftParticle1.gameObject.SetActive(false);
                carParticles.shiftParticle2.gameObject.SetActive(false);

                //carParticles.shiftParticle1.emissionRate = Mathf.Lerp(carParticles.shiftParticle1.emissionRate, 0, Time.deltaTime * 10.0f);
                //carParticles.shiftParticle2.emissionRate = Mathf.Lerp(carParticles.shiftParticle2.emissionRate, 0, Time.deltaTime * 10.0f);
            }
        }
    }
    public bool controlactive = false;
    public bool gasPress = false;

    public float _rpm;
    float neutralAccel;
    void FixedUpdate()
    {
        if (raceCarActive)
        {
            // speed of car

            speed = myRigidbody.velocity.magnitude * 2.7f;

            if (speed < lastSpeed - 10 && slip < 10)
                slip = lastSpeed / 15;

            lastSpeed = speed;

            if (slip2 != 0.0f)
                slip2 = Mathf.MoveTowards(slip2, 0.0f, 0.1f);


            myRigidbody.centerOfMass = carSetting.shiftCentre;




            if (carWheels.wheels.frontWheelDrive || carWheels.wheels.backWheelDrive)
            {
                if (Input.GetAxis("Horizontal") != 0)
                {
                    steer = Input.GetAxis("Horizontal");
                }
                else
                {
                    steer = floatingJoystick.Horizontal;
                }
                if (accel == 0 && speed <= 1 && brake)
                {
                    currentGear = 0;
                }

                //brake = Input.GetButton("Jump");

                    //if (accel == 0 && currentGear > 0)
                    //{
                    //    brake = true;
                    //}

                    //shift = Input.GetKey(KeyCode.LeftShift) | Input.GetKey(KeyCode.RightShift);
            }

            //if (!carSetting.automaticGear)
            //{
            //    if (Input.GetKeyDown(KeyCode.K))
            //    {
            //        ShiftUp();
            //    }
            //    if (Input.GetKeyDown(KeyCode.L))
            //    {
            //        ShiftDown();
            //    }
            //}





            if (!carWheels.wheels.frontWheelDrive && !carWheels.wheels.backWheelDrive)
                accel = 0.0f;

            if (carSetting.carSteer)
                carSetting.carSteer.localEulerAngles = new Vector3(steerCurAngle.x, steerCurAngle.y, steerCurAngle.z + (steer * -120.0f));

            if (carSetting.automaticGear && (currentGear == 1) && (accel < 0.0f))
            {
                if (speed < 5.0f) ShiftDown();
            }

            else if (carSetting.automaticGear && (currentGear == 0) && (accel > 0.0f))
            {
                if (speed < 5.0f) ShiftUp();
            }
            else if (carSetting.automaticGear && (motorRPM > carSetting.shiftUpRPM) && (accel > 0.0f) && speed > 10.0f && !brake)
            {
                ShiftUp();
            }
            else if (carSetting.automaticGear && (currentGear > 1) && (motorRPM < carSetting.shiftDownRPM))
            {
                ShiftDown();
            }


            if (speed < 1.0f) Backward = true;


            if (currentGear == 0 && Backward == true)
            {
                float shiftZ = -accel / -5;
                shiftZ = Mathf.Clamp(shiftZ, -0.02f, 0.02f);

                if (shiftZ < 0.0001f && shiftZ > -0.0001f)
                {
                    shiftZ = 0;
                }
                carSetting.shiftCentre.z = shiftZ;
                //if (speed < carSetting.gears[0] * -10)
                //    accel = -accel;
            }
            else
            {
                Backward = false;
                if (currentGear > 0)
                {
                    float shiftZ = -(accel / currentGear) / -5;
                    shiftZ = Mathf.Clamp(shiftZ, -0.02f, 0.02f);

                    if (shiftZ < 0.0001f && shiftZ > -0.0001f)
                    {
                        shiftZ = 0;
                    }

                    carSetting.shiftCentre.z = shiftZ;
                }
            }


            float shiftX = -Mathf.Clamp(steer * (speed / 100), -0.03f, 0.03f);

            if (shiftX < 0.0001f && shiftX > -0.0001f)
            {
                shiftX = 0;
            }

            carSetting.shiftCentre.x = shiftX;



            foreach (GameObject brakeLight in carLights.brakeLights_decal)
            {
                if (brake || accel < 0 || speed < 1.0f)
                {
                    brakeLight.SetActive(true);
                }
                else
                {
                    brakeLight.SetActive(false);

                }
            }


            wantedRPM = (9000.0f * accel) * 0.1f + wantedRPM * 0.9f;

            float rpm = 0.0f;
            int motorizedWheels = 0;
            bool floorContact = false;
            int currentWheel = 0;


            if (currentGear > 0)
                myRigidbody.AddRelativeTorque(0, steer * 10000, 0);
            else
                myRigidbody.AddRelativeTorque(0, -steer * 10000, 0);


            foreach (WheelComponent w in wheels)
            {
                WheelHit hit;
                WheelCollider col = w.collider;

                if (w.drive)
                {
                    if (!neutralGear && brake && currentGear < 2)
                    {
                        rpm += accel * carSetting.idleRPM;
                    }
                    else
                    {
                        if (!neutralGear)
                        {
                            rpm += col.rpm;
                        }
                        else
                        {
                            neutralAccel = Mathf.Lerp(neutralAccel, accel, Time.deltaTime);
                            rpm += 1.5f * (carSetting.idleRPM * neutralAccel);
                        }
                    }

                    motorizedWheels++;
                }


                if (brake || accel < 0.0f)
                {
                    if ((accel < 0.0f) || (brake && (w == wheels[2] || w == wheels[3])))
                    {
                        if (brake && (accel > 0.0f))
                        {
                            slip = Mathf.Lerp(slip, 5.0f, accel * 0.01f);
                        }
                        else if (speed > 1.0f)
                        {
                            slip = Mathf.Lerp(slip, 1.0f, 0.002f);
                        }
                        else
                        {
                            slip = Mathf.Lerp(slip, 1.0f, 0.02f);
                        }

                        wantedRPM = 0.0f;
                        col.brakeTorque = carSetting.brakePower;
                        w.rotation = w_rotate;

                    }
                }
                else
                {

                    //col.brakeTorque = accel == 0 || NeutralGear ? col.brakeTorque = 1000 : col.brakeTorque = 0;
                    if (accel == 0 || neutralGear)
                    {
                        col.brakeTorque = 1000;
                    }
                    else
                    {
                        col.brakeTorque = 0;
                    }

                    slip = speed > 0.0f ?
        (speed > 100 ? slip = Mathf.Lerp(slip, 1.0f + Mathf.Abs(steer), 0.02f) : slip = Mathf.Lerp(slip, 1.5f, 0.02f))
        : slip = Mathf.Lerp(slip, 0.01f, 0.02f);

                    w_rotate = w.rotation;

                }

                WheelFrictionCurve fc = col.forwardFriction;

                fc.asymptoteValue = 5000.0f;
                fc.extremumSlip = 2.0f;
                fc.asymptoteSlip = 20.0f;
                fc.stiffness = carSetting.stiffness / (slip + slip2);
                col.forwardFriction = fc;
                fc = col.sidewaysFriction;
                fc.stiffness = carSetting.stiffness / (slip + slip2);

                fc.extremumSlip = 0.3f + Mathf.Abs(steer);

                col.sidewaysFriction = fc;





                w.rotation = Mathf.Repeat(w.rotation + Time.deltaTime * col.rpm * 360.0f / 60.0f, 360.0f);
                float wheelAngle = col.steerAngle;
                wheelAngle *= 2;
                wheelAngle = Mathf.Clamp(wheelAngle, -carSetting.maxSteerAngle, carSetting.maxSteerAngle);
                w.rotation2 = Mathf.Lerp(w.rotation2, wheelAngle, 0.1f);
                w.wheel.localRotation = Quaternion.Euler(w.rotation, w.rotation2, 0.0f);


                Vector3 lp = w.wheel.localPosition;

                if (col.GetGroundHit(out hit))
                {

                    if (carParticles.brakeParticlePerfab)
                    {
                        if (Particle[currentWheel] == null)
                        {
                            Particle[currentWheel] = Instantiate(carParticles.brakeParticlePerfab, w.wheel.position, Quaternion.identity) as GameObject;
                            Particle[currentWheel].name = "WheelParticle";
                            Particle[currentWheel].transform.parent = transform.transform;

                            Particle[currentWheel].AddComponent<AudioSource>();
                            Particle[currentWheel].GetComponent<AudioSource>().maxDistance = 100;
                            Particle[currentWheel].GetComponent<AudioSource>().volume = 0.6f;
                            Particle[currentWheel].GetComponent<AudioSource>().spatialBlend = 1;
                            Particle[currentWheel].GetComponent<AudioSource>().dopplerLevel = 1;
                            Particle[currentWheel].GetComponent<AudioSource>().rolloffMode = AudioRolloffMode.Custom;
                        }


                        var pc = Particle[currentWheel].GetComponent<ParticleSystem>();
                        var emission = pc.emission;

                        bool WGrounded = false;

                        slipRate = 1.0f;

                        //for (int i = 0; i < carSetting.hitGround.Length; i++)
                        //{

                        //if (hit.collider.CompareTag(carSetting.hitGround[i].tag))
                        //if (LayerMask.LayerToName(hit.collider.gameObject.layer) == (carSetting.hitGround[i].tag))

                        float _speed = speed;
                        _speed = Mathf.Clamp(_speed, 100, 200);
                        if (brake)
                        {
                            Particle[currentWheel].GetComponent<AudioSource>().clip = carSetting.hitGround[0].brakeSound;
                            Particle[currentWheel].GetComponent<AudioSource>().volume = 0.6f * (_speed / 200);
                        }
                        else
                        {
                            //Particle[currentWheel].GetComponent<AudioSource>().volume = 0.1f;
                            Particle[currentWheel].GetComponent<AudioSource>().clip = carSetting.hitGround[0].groundSound;
                        }



                        if (speed > 5 && !brake)
                        {
                            emission.enabled = false;

                            float currentEmissionRate = emission.rateOverTime.constant;
                            currentEmissionRate = Mathf.Lerp(currentEmissionRate, 0f, 0.1f);

                            emission.rateOverTime = new ParticleSystem.MinMaxCurve(currentEmissionRate);


                            Particle[currentWheel].GetComponent<AudioSource>().volume = Mathf.Lerp(Particle[currentWheel].GetComponent<AudioSource>().volume, 0, Time.deltaTime * 10.0f);

                            if (!Particle[currentWheel].GetComponent<AudioSource>().isPlaying)
                            {
                                Particle[currentWheel].GetComponent<AudioSource>().Play();
                            }

                        }
                        else if ((brake || Mathf.Abs(hit.sidewaysSlip) > 0.2f) && speed > 1)
                        {

                            if ((accel < 0.0f) || ((brake || Mathf.Abs(hit.sidewaysSlip) > 0.2f) && (w == wheels[2] || w == wheels[3])))
                            {

                                emission.enabled = true;

                                float currentEmissionRate = emission.rateOverTime.constant;
                                currentEmissionRate = Mathf.Lerp(currentEmissionRate, 100.0f, 0.5f);

                                emission.rateOverTime = new ParticleSystem.MinMaxCurve(currentEmissionRate);

                                if (!Particle[currentWheel].GetComponent<AudioSource>().isPlaying)
                                {
                                    Particle[currentWheel].GetComponent<AudioSource>().Play();
                                }


                            }
                        }
                        else
                        {

                            float currentEmissionRate = emission.rateOverTime.constant;
                            currentEmissionRate = Mathf.Lerp(currentEmissionRate, 0.0f, 1f);

                            emission.rateOverTime = new ParticleSystem.MinMaxCurve(currentEmissionRate);

                            if (emission.rateOverTime.constant < 2.0f)
                            {

                                emission.enabled = false;
                            }


                            Particle[currentWheel].GetComponent<AudioSource>().volume = Mathf.Lerp(Particle[currentWheel].GetComponent<AudioSource>().volume, 0, Time.deltaTime * 10.0f);
                        }

                    }

                    lp.y -= Vector3.Dot(w.wheel.position - hit.point, transform.TransformDirection(0, 1, 0) / transform.lossyScale.x) - (col.radius);
                    lp.y = Mathf.Clamp(lp.y, -10.0f, w.pos_y);
                    floorContact = floorContact || (w.drive);

                }
                else
                {


                    if (Particle[currentWheel] != null)
                    {
                        var pc = Particle[currentWheel].GetComponent<ParticleSystem>();
                        var emission = pc.emission;



                        float currentEmissionRate = emission.rateOverTime.constant;
                        currentEmissionRate = Mathf.Lerp(currentEmissionRate, 0.0f, 0.5f);

                        emission.rateOverTime = new ParticleSystem.MinMaxCurve(currentEmissionRate);
                        if (emission.rateOverTime.constant < 2.0f)
                        {

                            emission.enabled = false;
                        }


                    }

                    lp.y = w.startPos.y - carWheels.setting.Distance;
                    myRigidbody.AddForce(Vector3.down * 5000);

                }

                currentWheel++;
                w.wheel.localPosition = lp;
            }


            if (motorizedWheels > 1)
            {
                rpm = rpm / motorizedWheels;
            }
            _rpm = rpm;
            motorRPM = 0.95f * motorRPM + 0.05f * Mathf.Abs(rpm * carSetting.gearFactor * carSetting.gears[currentGear]);

            if (motorRPM > carSetting.maxRPM)
            {
                redlineCounter += 10 * Time.deltaTime;
                redlineValue = Mathf.Abs(Mathf.Sin(Mathf.PI * redlineCounter));
                motorRPM = 50 + carSetting.maxRPM + redlineValue * 250;
                //motorRPM = carSetting.maxRPM;

                timeStep += Time.deltaTime;
                if (timeStep > 1f)
                {
                    timeStep = 0f;
                    carParticles.afterBurn.Play();
                }
            }
            if (motorRPM < carSetting.idleRPM) motorRPM = carSetting.idleRPM;

            float newTorque = NewTorqueCalculater();

            foreach (WheelComponent w in wheels)
            {
                WheelCollider col = w.collider;

                if (w.drive)
                {

                    if (Mathf.Abs(col.rpm) > Mathf.Abs(wantedRPM) || gearShiftingAcitve)
                    {
                        col.motorTorque = 0;
                    }
                    else
                    {
                        float curTorqueCol = col.motorTorque;

                        if (!brake && accel != 0 && neutralGear == false)
                        {
                            if ((speed < carSetting.LimitForwardSpeed && currentGear > 0) || (speed < carSetting.LimitBackwardSpeed && currentGear == 0))
                            {
                                if (motorRPM >= Mathf.Abs(carSetting.maxRPM))
                                {
                                    col.motorTorque = 0;
                                    col.brakeTorque = 0;
                                }
                                else
                                {
                                    col.motorTorque = curTorqueCol * 0.9f + newTorque * 1.0f;
                                }
                            }
                            else
                            {
                                col.motorTorque = 0;
                                col.brakeTorque = 0;
                            }
                        }
                        else
                        {
                            col.motorTorque = 0;

                        }
                    }
                }

                if (brake || slip2 > 2.0f)
                {
                    col.steerAngle = Mathf.Lerp(col.steerAngle, steer * w.maxSteer, 0.05f);
                }
                else
                {
                    float SteerAngle = Mathf.Clamp(speed / carSetting.maxSteerAngle, 1.0f, carSetting.maxSteerAngle);
                    col.steerAngle = steer * (w.maxSteer / SteerAngle);
                }
                torqCurrent = col.motorTorque;
            }

            // calculate pitch (keep it within reasonable bounds)
            Pitch = Mathf.Clamp(1.2f + ((motorRPM - carSetting.idleRPM) / (carSetting.shiftUpRPM - carSetting.idleRPM)), 1.0f, 10.0f);

            shiftTime = Mathf.MoveTowards(shiftTime, 0.0f, 0.1f);


            if (realisticEngineSound != null)
            {
                realisticEngineSound.engineCurrentRPM = motorRPM;
                if (accel > 0.2f)
                {
                    realisticEngineSound.gasPedalPressing = true;
                }
                else
                {
                    realisticEngineSound.gasPedalPressing = false;
                }
            }
            if (motorRPM > 4000)
            {
                carSounds.turboOn.volume = (motorRPM - 4000) / (carSetting.maxRPM - 4000);
            }




            if (speedCheck && speed >= 100)
            {
                speedCheck = false;
            }
        }
    }
    bool speedCheck = true;

    public float NewTorqueCalculater()
    {
        int index = (int)(motorRPM / efficiencyTableStep);
        if (index >= torqueDatas[currentGear].torqueTable.Count)
        {
            index = torqueDatas[currentGear].torqueTable.Count - 1;
        }
        if (index < 0)
        {
            index = 0;
        }
        float nwtrq = torqueFactor * curTorque * carSetting.gearFactor * carSetting.gears[currentGear] * torqueDatas[currentGear].torqueTable[index];
        return nwtrq;
    }
    IEnumerator GearShifting()
    {
        float counter = 0f;

        while (counter < carSetting.gearShiftSpeed)
        {
            counter += Time.deltaTime;
            gearShiftingAcitve = true;
            yield return null;
        }
        gearShiftingAcitve = false;
    }
    //public float NewTorqueCalculater()
    //{
    //    int index = (int)(motorRPM / efficiencyTableStep);
    //    if (index >= efficiencyTable.Length)
    //    {
    //        index = efficiencyTable.Length - 1;
    //    }
    //    if (index < 0)
    //    {
    //    }
    //    float nwtrq = curTorque * carSetting.gears[currentGear] * efficiencyTable[index];
    //    return nwtrq;
    //}
    /////////////// Show Normal Gizmos ////////////////////////////
    public float torqCurrent = 0f;
    //        index = 0;
    float redlineValue = 0;
    float redlineCounter = 0;
    //void OnDrawGizmos()
    //{

    //    if (!carSetting.showNormalGizmos || Application.isPlaying) return;

    //    Matrix4x4 rotationMatrix = Matrix4x4.TRS(transform.position, transform.rotation, transform.lossyScale);

    //    Gizmos.matrix = rotationMatrix;
    //    Gizmos.color = new Color(1, 0, 0, 0.5f);
    //    Gizmos.DrawCube(Vector3.up / 1.5f, new Vector3(2.5f, 2.0f, 6));
    //    Gizmos.DrawSphere(carSetting.shiftCentre / transform.lossyScale.x, 0.2f);

    //}

    [System.Serializable]
    public struct TorqueDatas
    {
        public List<float> torqueTable;

    }
    public List<TorqueDatas> torqueDatas;

    public float efficiencyTableStep = 250.0f;
    float timeStep = 0f;

    public Vector2 earlyRPMarea;
    public Vector2 goodRPMarea;
    public Vector2 perfectRPMarea;
    public Vector2 lateGoodRPMarea;
    public Vector2 lateRPMarea;
    public Vector2 redZoneRPMarea;
    public List<int> perfectIndexList = new List<int>();
    public List<int> goodIndexList = new List<int>();
    public List<int> lateGoodIndexList = new List<int>();
    public float _autoRPM_Shift_Up;
   
    public Vector3 saveVelocity;
    public int gearSave;
    public float mtrRpm;
    public float saveTorque;
    public float rpmSave;

    bool saveActive = false;
    float speedSave;
    public void VelocitySave()
    {
        saveActive = true;
        foreach (WheelComponent w in wheels)
        {
            WheelCollider col = w.collider;
            saveTorque = col.motorTorque;
            rpmSave = col.rpm;
        }

        speedSave = speed;
        saveVelocity = myRigidbody.velocity;
        myRigidbody.isKinematic = true;
        gearSave = currentGear;
        mtrRpm = motorRPM;
        StartCoroutine(SaveMotor());
    }
    IEnumerator SaveMotor()
    {
        while (saveActive)
        {
            motorRPM = mtrRpm;
            speed = speedSave;
            carSetting.brakePower = 5000;
            foreach (WheelComponent w in wheels)
            {
                WheelCollider col = w.collider;
                col.motorTorque = saveTorque;
            }
            accel= 2f;
            yield return null;
        }
    }
    public void VelocityInit()
    {
        saveActive = false;

        myRigidbody.isKinematic = false;
        myRigidbody.velocity = saveVelocity;
        currentGear = gearSave;
        motorRPM = mtrRpm;


        foreach (WheelComponent w in wheels)
        {
            WheelCollider col = w.collider;
            col.motorTorque = 10000;
        }

    }
}