using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
public class FloatingJoystick : MonoBehaviour, IDragHandler, IPointerDownHandler, IPointerUpHandler
{     
    [SerializeField(), Range(1.0f, 20.0f)] private float sensivity;

    public JoyStickDirection JoystickDirection = JoyStickDirection.Both;
    public RectTransform Background;
    public RectTransform Handle;
    [Range(0, 10f)] public float HandleLimit = 1f;
    private Vector2 direction = new Vector2(0, 1);
    private Vector2 speed = Vector2.zero;
    //Output
    public float Vertical { get { return direction.y; } }
    public float Horizontal { get { return direction.x; } }
    Vector2 JoyPosition = Vector2.zero;
    public bool pressActive;
    bool pressActive2 = false;
    public void FirstClick( )
    {
        pressActive2 = true;
        PointerEventData eventdata = new PointerEventData(EventSystem.current);
        pressActive = true;
        Background.gameObject.SetActive(true);
        StartCoroutine(OnDrag2());

        JoyPosition = Input.mousePosition;
        Background.position = Input.mousePosition;
        Handle.anchoredPosition = Vector2.zero;
    }
    IEnumerator OnDrag2()
    {
        while (pressActive2)
        {
            Vector2 mousePos = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
            Vector2 JoyDriection = mousePos - JoyPosition;
            direction = (JoyDriection.magnitude > Background.sizeDelta.x / 2f) ? JoyDriection.normalized :
            speed = (JoyDriection.magnitude > Background.sizeDelta.x / 2f) ? JoyDriection.normalized :

                JoyDriection / (Background.sizeDelta.x / 2f);
            if (JoystickDirection == JoyStickDirection.Horizontal)
            {
                direction = new Vector2(direction.x, 0f);
                speed = new Vector2(speed.x, 0f);


            }
            if (JoystickDirection == JoyStickDirection.Vertical)
            {
                direction = new Vector2(0f, direction.y);
                speed = new Vector2(0f, speed.y);

            }
            Handle.anchoredPosition = (sensivity * direction * Background.sizeDelta.x / 20f) * HandleLimit;

            if (Vector2.Distance(mousePos, Background.position) > 2 * Vector2.Distance(Background.position, Handle.position))
            {
                Background.position = Vector3.Lerp(Background.position, mousePos, 2 * Time.deltaTime);
                JoyPosition = Background.position;

            }

            if (Input.GetMouseButtonUp(0))
            {
                pressActive2 = false;
            }

            yield return null;
        }
        pressActive = false;
        Background.gameObject.SetActive(false);
        speed = Vector2.zero;
        Handle.anchoredPosition = Vector2.zero;
    }
    public void OnPointerDown(PointerEventData eventdata)
    {
        direction = Vector2.zero;
        pressActive = true;
        Background.gameObject.SetActive(true);
        OnDrag(eventdata);
        JoyPosition = eventdata.position;
        Background.position = eventdata.position;
        Handle.anchoredPosition = Vector2.zero;

    }
    public void OnDrag(PointerEventData eventdata)
    {
        Vector2 JoyDriection = eventdata.position - JoyPosition;
        direction = (JoyDriection.magnitude > Background.sizeDelta.x / 2f) ? JoyDriection.normalized :
        speed = (JoyDriection.magnitude > Background.sizeDelta.x / 2f) ? JoyDriection.normalized :

            JoyDriection / (Background.sizeDelta.x / 2f);
        if (JoystickDirection == JoyStickDirection.Horizontal)
        {
            direction = new Vector2(direction.x, 0f);
            speed = new Vector2(speed.x, 0f);


        }
        if (JoystickDirection == JoyStickDirection.Vertical)
        {
            direction = new Vector2(0f, direction.y);
            speed = new Vector2(0f, speed.y);

        }
        Handle.anchoredPosition = (sensivity * direction * Background.sizeDelta.x / 20f) * HandleLimit;

        if(Vector2.Distance(eventdata.position , Background.position) > 2 * Vector2.Distance(Background.position, Handle.position))
        {
            Background.position = Vector3.Lerp(Background.position, eventdata.position, 2 * Time.deltaTime);
            JoyPosition = Background.position;

        }
    }
    public void OnPointerUp(PointerEventData eventdata)
    {
        direction = Vector2.zero;
        pressActive = false;
        Background.gameObject.SetActive(false);
        speed = Vector2.zero;
        Handle.anchoredPosition = Vector2.zero;
    }

    public void PointerUpManuel()
    {
        pressActive = false;
        Background.gameObject.SetActive(false);
        speed = Vector2.zero;
        Handle.anchoredPosition = Vector2.zero;
    }
}

