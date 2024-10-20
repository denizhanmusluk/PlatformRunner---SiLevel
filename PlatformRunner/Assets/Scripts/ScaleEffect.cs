using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScaleEffect : MonoBehaviour
{
    public float maxScaleFactor = 2f;
    public float speed = 1f;
    public float damping = 0.5f;

    private Vector3 initialScale;

    void Start()
    {
        initialScale = transform.localScale;
    }

    public IEnumerator ScaleAnimation()
    {
        float counter = 0;
        while(counter < 1f)
        {
            counter += Time.deltaTime * speed;
            float scaleFactor = 1 + Mathf.Sin(counter) * (maxScaleFactor - 1) * Mathf.Exp(-damping * counter);
            transform.localScale = initialScale * scaleFactor;
            yield return null;
        }
    }
}
