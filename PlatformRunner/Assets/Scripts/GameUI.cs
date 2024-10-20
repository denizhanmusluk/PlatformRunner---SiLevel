using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class GameUI : Singleton<GameUI>
{

    [System.Serializable]
    public class CarUI
    {
        public Image tachometerNeedle;
        public Image tachometerSlider;

        public TextMeshProUGUI speedText;
        public TextMeshProUGUI gearText;
        public TextMeshProUGUI gearTextChar;

        public GameObject speedTextParentGO;
        public TextMeshProUGUI rpmText;


    }
    [System.Serializable]
    public class Panels
    {
        public GameObject gearShiftPanel;
        public GameObject accelButtonPanel;
        public GameObject brakeButtonPanel;
        public GameObject nosButtonPanel;
    }
    public FloatingJoystick floatingJoystick;
    public TextMeshProUGUI startTimeText;
    public CarUI carUI;
    public Panels panels;
    public VehicleControl vehicleControl;
    private float tachometerAngle = -150;


    private void Start()
    {
        ResetUIComponents();
    }
    public void RaceStart()
    {
        if (!Globals.startedRace)
        {
            Globals.startedRace = true;
            DnzEvents.GameUpdate += ShowCarUI;
            StartCoroutine(StartingRaceTimer());
        }
    }


    public void ShowCarUI()
    {


        int gearst = vehicleControl.currentGear;
        carUI.speedText.text = ((int)vehicleControl.speed).ToString();
        if ((int)vehicleControl.speed == 100)
        {
            //Debug.Log("0 - 100 km/s = " + raceTimer);
        }
        if (gearst > 0 && vehicleControl.speed > 1)
        {
            //carUI.gearText.color = Color.green;
            carUI.gearText.text = gearst.ToString();
            string gearCh = "th";
            if (gearst == 1)
            {
                gearCh = "st";
            }
            else if (gearst == 2)
            {
                gearCh = "nd";
            }
            else if (gearst == 3)
            {
                gearCh = "rd";
            }
            carUI.gearTextChar.text = gearCh;
        }
        else if (vehicleControl.speed > 1)
        {
            carUI.gearText.color = Color.red;
            carUI.gearText.text = "R";
            carUI.gearTextChar.text = "";
        }
        else
        {
            carUI.gearText.color = Color.white;
            carUI.gearText.text = "N";
            carUI.gearTextChar.text = "";
        }

        //thisAngle = (AIControl.CurrentVehicle.motorRPM / 20) - 175;
        tachometerAngle = (vehicleControl.motorRPM / 50f) - 90;
        tachometerAngle = Mathf.Clamp(tachometerAngle, -180, 90);
        carUI.rpmText.text = ((int)vehicleControl.motorRPM).ToString();

        carUI.tachometerNeedle.rectTransform.rotation = Quaternion.Euler(0, 0, -tachometerAngle);

        if (vehicleControl.motorRPM < 3000)
        {
            carUI.tachometerSlider.fillAmount = vehicleControl.motorRPM / 9000f + 0.01f;
        }
        else
        {
            carUI.tachometerSlider.fillAmount = vehicleControl.motorRPM / 9000f;
        }
    }

    IEnumerator StartingRaceTimer()
    {
        int counter = 3;
        while (counter > 0)
        {
            startTimeText.text = $"{counter}s";
            counter--;
            if (startTimeText.GetComponent<ScaleEffect>() != null)
            {
                StartCoroutine(startTimeText.GetComponent<ScaleEffect>().ScaleAnimation());
            }
            yield return new WaitForSeconds(1f);
        }
        startTimeText.text = $"Start";
        DnzEvents.GameStartEvent();
        SetUIComponents();
        yield return new WaitForSeconds(1f);
        startTimeText.gameObject.SetActive(false);
    }
    void SetUIComponents()
    {
        carUI.speedTextParentGO.SetActive(true);
        carUI.rpmText.gameObject.SetActive(false);
        panels.accelButtonPanel.SetActive(false);
        panels.brakeButtonPanel.SetActive(true);
        panels.gearShiftPanel.SetActive(true);
        panels.nosButtonPanel.SetActive(true);
    }
    void ResetUIComponents()
    {
        carUI.speedTextParentGO.SetActive(false);
        carUI.rpmText.gameObject.SetActive(true);
        panels.accelButtonPanel.SetActive(true);
        panels.brakeButtonPanel.SetActive(false);
        panels.gearShiftPanel.SetActive(false);
        panels.nosButtonPanel.SetActive(false);
    }
}
