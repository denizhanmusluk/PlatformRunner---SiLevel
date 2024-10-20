using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObjects/CarListSet")]

public class CarListSettings : ScriptableObject
{
    [Header("Car List")]
    [SerializeField] private VehicleControl[] carPrefabList;
    public VehicleControl[] _carPrefabList { get { return carPrefabList; } }
}
