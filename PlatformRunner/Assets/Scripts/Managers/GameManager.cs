using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using ObserverSystem;

public class GameManager : Observer
{
    private static GameManager _instance = null;
    public static GameManager Instance => _instance;

    public LevelManager lvlManager;
    public UIManager ui;

    float firstTime;
    private void Awake()
    {
        _instance = this;
        InitConnections();
        lvlManager.LevelInit();
        firstTime = Time.timeScale;
    }
    void InitConnections()
    {
        ui.OnLevelStart += OnLevelStart;
        ui.OnNextLevel += OnNextLevel;
        ui.OnLevelRestart += OnLevelRestart;
        ui.OnGamePaused += OnLevelPause;
        ui.OnGameResume += OnLevelResume;
    }
    void Start()
    {

        Application.targetFrameRate = 60;


        ObserverManager.Instance.RegisterObserver(this, SubjectType.GameState);
    }
    void OnLevelStart()
    {
        ui.startCanvas.SetActive(false);
    }

    void OnNextLevel()
    {
        Globals.currentLevel++;
        PlayerPrefs.SetInt("levelIndex", Globals.currentLevel);

        Globals.currentLevelIndex++;
        if (Globals.LevelCount - 1 < Globals.currentLevelIndex)
        {
            Globals.currentLevelIndex = Random.Range(0, Globals.LevelCount - 1);
            PlayerPrefs.SetInt("level", Globals.currentLevelIndex);
        }
        else
        {
            PlayerPrefs.SetInt("level", Globals.currentLevelIndex);
        }


        int levelIndex = PlayerPrefs.GetInt("levelIndex");
        string levelId = levelIndex.ToString();
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
    public void OnLevelRestart()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        Globals.startedRace = false;
        Globals.currentLevel = 0;
        Globals.currentLevelIndex = 0;
        Globals.LevelCount = 0;
    }
    public void OnLevelPause()
    {
        Time.timeScale = 0;
    }
    public void OnLevelResume()
    {
        Time.timeScale = firstTime;
    }

    public override void OnNotify(NotificationType notificationType) //observer notify
    {
        switch (notificationType)
        {
            case NotificationType.Start:
                {
                    StartState();
                }
                break;
            case NotificationType.End:
                {

                }
                break;
            case NotificationType.Win:
                {
                    Invoke("WinState", 0);
                    Debug.Log("win");
                }
                break;
            case NotificationType.Fail:
                {
                    Invoke("FailState", 2);
                    Debug.Log("fail");
                }
                break;

        }
    }
    public void StartState()
    {
    }
    public void FailState()
    {

    }
    public void WinState()
    {
        //ui.finishCanvas.SetActive(true);
        ui.NextLevelButton();
    }
}
