using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelManager : Singleton<LevelManager>
{
    public CarListSettings carListSettings;
    public GameObject loadedLevel;

    [SerializeField] private List<LevelScriptable> levelList;
    
    [SerializeField] int levelIteration = 3;
    public int levelDestroyIteration = 2;
    [SerializeField] List<PlatformBase> platformPrefabs;

    [SerializeField] private Transform carCreatePos_TR;


    public List<PlatformBase> platformPool = new List<PlatformBase>();
    private PlatformBase lastPlatform;

    public void LevelInit()
    {
        Globals.currentLevel = PlayerPrefs.GetInt("levelIndex", 0);

        if (levelList.Count > 0)
        {
            lastPlatform = SpawnPlatform(Vector3.zero, Vector3.forward);
            for (int iter = 0; iter < levelIteration; iter++)
            {
                SpawnNextPlatform();
            }
        }
        CarCreate();
    }
    public void CreateNextLevel()
    {
        SpawnNextPlatform();
        platformPool[0].gameObject.SetActive(false);
    }
    void SpawnNextLevel()
    {
   
        //loadedLevel = Instantiate(levelList[Globals.currentLevel]._levelPrefab, transform.position, Quaternion.identity);
       
    }
    PlatformBase SpawnPlatform(Vector3 entryPosition, Vector3 entryDirection)
    {
        // Havuzdan platform çek
        PlatformBase platform = GetPlatformFromPool();
        platform.Configure(entryPosition, entryDirection);
        Globals.currentLevel++;
        //Globals.currentLevel = PlayerPrefs.GetInt("levelIndex", 0);

        return platform;
    }
    void SpawnNextPlatform()
    {
        Vector3 nextEntryPosition = lastPlatform.ExitPosition;
        Vector3 nextEntryDirection = lastPlatform.GetExitDirection();

        PlatformBase nextPlatform = platformPrefabs[Random.Range(0, platformPrefabs.Count)];
        lastPlatform = SpawnPlatform(nextEntryPosition, nextEntryDirection);
    }

    PlatformBase GetPlatformFromPool()
    {
        foreach (PlatformBase platform in platformPool)
        {
            if (!platform.gameObject.activeInHierarchy)
            {
                platform.gameObject.SetActive(true);
                platformPool.Add(platformPool[0]);
                platformPool.RemoveAt(0);
                return platform;
            }
        }

        int levelId = (Globals.currentLevel < platformPrefabs.Count) ? Globals.currentLevel : Random.Range(0, platformPrefabs.Count);

        PlatformBase newPlatform = Instantiate(platformPrefabs[levelId]);
        platformPool.Add(newPlatform);
        return newPlatform;
    }



    void CarCreate()
    {
        int carSelect = Random.Range(0, carListSettings._carPrefabList.Length);
        Instantiate(carListSettings._carPrefabList[carSelect], carCreatePos_TR.position, Quaternion.identity);
    }
}
