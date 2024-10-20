using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
public class RunButton : MonoBehaviour
{
    public KeyCode keyPress;

    public UnityEvent onPointerDown;
    public UnityEvent onPointerUp;
    //public void OnPointerUp(PointerEventData eventData)
    //{
    //    onPointerUp?.Invoke();
    //}
    //public void OnPointerDown(PointerEventData eventData)
    //{
    //    onPointerDown?.Invoke();
    //}
    private void Update()
    {
        if(Input.GetKeyDown(keyPress))
        {
            onPointerDown?.Invoke();
        }
        if (Input.GetKeyUp(keyPress))
        {
            onPointerUp?.Invoke();
        }
    }
}

