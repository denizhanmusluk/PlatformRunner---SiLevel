using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StraightPlatform : PlatformBase
{
    public float length = 10f;

    public override void Configure(Vector3 entryPosition, Vector3 entryDirection)
    {
        EntryPosition = entryPosition;
        ExitPosition = EntryPosition + entryDirection * length;
        transform.position = EntryPosition;
        transform.rotation = Quaternion.LookRotation(entryDirection);
    }
}
