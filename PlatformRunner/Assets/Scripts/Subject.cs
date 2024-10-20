using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace ObserverSystem
{
    public abstract class Subject : MonoBehaviour
    {
        private List<Observer> _observer = null;
        [SerializeField] private SubjectType _subjectType;
        public SubjectType SubjectType => _subjectType;
        public void RegisterObserver(Observer observer)
        {
            if (_observer == null)
            {
                _observer = new List<Observer>();
            }
            _observer.Add(observer);
        }
        public void RemoveObserver(Observer observer)
        {
            if (_observer.Count > 0)
            {
                _observer.Remove(observer);
            }
        }
        private void Start()
        {
            OnInit();
        }
        private void OnInit()
        {
            ObserverManager.Instance.RegisterSubject(this);
        }
        public void Notify(NotificationType notificationType)
        {
            foreach (var observer in _observer)
            {
                observer.OnNotify(notificationType);
            }
        }
    }
}