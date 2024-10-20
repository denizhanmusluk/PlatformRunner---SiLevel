using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckPoint : MonoBehaviour
{
    LevelManager levelManager;
    PlatformBase currentPlatform;
    private void Start()
    {
        levelManager = LevelManager.Instance;
    }
    private void LateUpdate()
    {
        currentPlatform = levelManager.platformPool[levelManager.levelDestroyIteration];
        if (Vector3.Distance(currentPlatform.ExitPosition, transform.position) < 4)
        {
            levelManager.CreateNextLevel();
        }
    }
}
