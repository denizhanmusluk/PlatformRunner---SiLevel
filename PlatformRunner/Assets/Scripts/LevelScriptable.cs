using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "ScriptableObjects/LevelSet")]
public class LevelScriptable : ScriptableObject
{
    [Header("LevelPrefabs")]
    [SerializeField] private GameObject levelPrefab;
    public GameObject _levelPrefab { get { return levelPrefab; } }
}
