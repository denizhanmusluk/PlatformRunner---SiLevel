using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CurvedPlatform : PlatformBase
{
    public float length = 10f;
    public float turnAngle = 90f;

    public override void Configure(Vector3 entryPosition, Vector3 entryDirection)
    {
        EntryPosition = entryPosition;
        Vector3 turnDirection = Quaternion.Euler(0, Random.Range(-turnAngle, turnAngle), 0) * entryDirection;
        ExitPosition = EntryPosition + turnDirection * length;
        transform.position = EntryPosition;
        transform.rotation = Quaternion.LookRotation(turnDirection);
    }
}