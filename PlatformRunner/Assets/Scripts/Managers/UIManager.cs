using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using TMPro;
using ObserverSystem;
using UnityEngine.UI;

public class UIManager : Subject
{
    public event Action OnLevelStart, OnNextLevel, OnLevelRestart, OnGamePaused, OnGameResume;

    [Header("Screens")]
    public GameObject startCanvas;
    public GameObject ingameCanvas;
    //public GameObject finishCanvas;
    //public GameObject failCanvas;
    public GameObject pauseMenu;
    public GameObject joyStick;
    void CheckAndDisplayStartScreen()
    {
        //startCanvas.SetActive(true);
        //int displayStart = PlayerPrefs.GetInt("displayStart");
        //if(displayStart > 0)
        //{
        //    startCanvas.SetActive(true);
        //}
        //else
        //{ 
        //    StartLevel();
        //    Invoke(nameof(StartLevelButton), DEFAULT_START_DELAY);
        //    PlayerPrefs.SetInt("displayStart", 1);
        //}
    }
    private void Awake()
    {

    }

    #region Handler Functions

    public void StartLevelButton()
    {
        OnLevelStart?.Invoke();
        Notify(NotificationType.Start);
    }
    public void NextLevel()
    {
        Notify(NotificationType.Win);
    }
    public void NextLevelButton()
    {
        OnNextLevel?.Invoke();
    }
    public void PauseLevelButton()
    {
        OnGamePaused?.Invoke();
    }

    public void ResumeLevelButton()
    {
        OnGameResume?.Invoke();
        pauseMenu.SetActive(false);
    }
    public void Fail()
    {
        Notify(NotificationType.Fail);
    }
    public void RestartLevelButton()
    {
        OnLevelRestart?.Invoke();
    }
    #endregion

    public void StartLevel()
    {
        startCanvas.SetActive(false);
    }

    public void FinishLevel()
    {
        ingameCanvas.SetActive(false);
    }

    public void FailLevel()
    {
        ingameCanvas.SetActive(false);
        //failCanvas.SetActive(true);
    }

 
}

