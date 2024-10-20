using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ControlManager : Singleton<ControlManager>
{
    public VehicleControl playerCar;
    public Button nosButton;
    public void GasPedal(bool gasActive)
    {
        if (gasActive)
        {
            playerCar.accel = 1f;
        }
        else
        {
            playerCar.accel = 0f;
        }
        GameUI.Instance.RaceStart();
    }
    public void BrakePedal(bool brakeActive)
    {
        playerCar.brake = brakeActive;
        if (brakeActive)
        {
            playerCar.accel = 0f;
        }
        else
        {
            playerCar.accel = 1f;
        }
    }
    public void ShiftUpPedal()
    {
        playerCar.ShiftUp();
    }
    public void ShiftDownPedal()
    {
        playerCar.ShiftDown();
    }
    public void NosButton()
    {
        if (nosButton.interactable)
        {
            nosButton.interactable = false;
            playerCar.shift = true;
            //playerCar.carParticles.lightingPAritcleGO.SetActive(true);
            playerCar.FrontSuspensionUp();
        }
    }
}
