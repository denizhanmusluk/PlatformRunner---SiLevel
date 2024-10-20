using System;
using UnityEngine;

public class DnzEvents : MonoBehaviour
{
    public static event Action RaceStart, GameUpdate, GameFixedUpdate, GameSuccess, GameFail;

    private void Awake() => ResetEvents();
    public void ResetEvents()
    {
        RaceStart = null;
        GameUpdate = null;
        GameSuccess = null;
        GameFail = null;

    }

    public static void GameStartEvent() => RaceStart?.Invoke();
    private void Update() => GameUpdate?.Invoke();
    private void FixedUpdate() => GameFixedUpdate?.Invoke();
    public static void GameSuccessEvent() => GameSuccess?.Invoke();
    public static void GameFailEvent() => GameFail?.Invoke();

    //public static void TyreSkidEvent() => TyreSkid?.Invoke();
    //public static void EndTyreSkidEvent() => EndTyreSkid?.Invoke();
    //public static void TyreSmokeEvent() => TyreSmoke?.Invoke();

}
