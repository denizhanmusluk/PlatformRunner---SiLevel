using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[System.Serializable]
public struct TorqueDatas
{
    public List<float> torqueTable;

}
[System.Serializable]
public struct Torques
{
    public List<TorqueDatas> torqueValues;

}
[System.Serializable]
public struct CarDatas
{
    public int price;
    public float power;
    public float tireFriction;
    public float shiftTime;
    public float weight;

}
[System.Serializable]
public struct NosDatas
{
    public int price;
    public float nosPowerRatio;
    public float nosCapacity;
}

[CreateAssetMenu(menuName = "ScriptableObjects/CarSettings")]

public class CarSettings : ScriptableObject
{
    //[Header("       CAR UPGRADE LEVEL")]
    //public int engineUpgradeLevel;
    //public int bodyUpgradeLevel;
    //public int tiresUpgradeLevel;
    //public int transmissionUpgradeLevel;
    //public int nosUpgradeLevel;



    [Header("       CAR PRICE")]
    public int carPrice_money;
    public int carPrice_gem;

    [Header("       CAR UPGRADE")]

    [Header("Engine")]
    public List<CarDatas> engineUpgrade;

    [Header("Tires")]
    public List<CarDatas> tiresUpgrade;

    [Header("Transmission")]
    public List<CarDatas> transmissionUpgrade;

    [Header("Body")]
    public List<CarDatas> bodyUpgrade;
    public float weightFactor;
    [Header("Nitro Oxide")]
    public List<NosDatas> nosUpgrade;


    [Header("SEGMENT")]
    public string carSegmentName;

    [Header("Model Name")]
    public string modelName;

    [Header("Automatic Gear Shift RPM")]
    //[SerializeField] private int[] autoRPM_Shift_Up;
    //public int[] _autoRPM_Shift_Up { get { return autoRPM_Shift_Up; } }

    [Header("Automatic Gear Shift RPM")]
    //[SerializeField] private int[] autoRPM_Shift_Down;
    //public int[] _autoRPM_Shift_Down { get { return autoRPM_Shift_Down; } }


    [Header("       Torque Datas")]

    public List<Torques> torques;

    public float efficiencyTableStep = 250.0f;

    [Header("       Unlock Level")]
    public int unlockLevel;

}
