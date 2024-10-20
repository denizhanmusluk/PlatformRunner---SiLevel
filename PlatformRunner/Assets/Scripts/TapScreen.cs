using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

public class TapScreen : MonoBehaviour, IPointerUpHandler, IPointerDownHandler,IPointerEnterHandler
{
    public UnityEvent onPointerDown;
    public UnityEvent onPointerUp;
    public UnityEvent onPointerEnter;
    public void OnPointerUp(PointerEventData eventData)
    {
        onPointerUp?.Invoke();
    }
    public void OnPointerDown(PointerEventData eventData)
    {
        onPointerDown?.Invoke();
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        onPointerEnter?.Invoke();
    }
}