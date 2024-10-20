using UnityEngine;

public abstract class PlatformBase : MonoBehaviour
{
    public Vector3 EntryPosition { get; protected set; } 
    public Vector3 ExitPosition { get; protected set; }
    public int platformID;
    public abstract void Configure(Vector3 entryPosition, Vector3 entryDirection);


    public virtual Vector3 GetExitDirection()
    {
        return (ExitPosition - EntryPosition).normalized;
    }
    private void OnEnable()
    {
        platformID = Globals.currentLevel;
    }
}
