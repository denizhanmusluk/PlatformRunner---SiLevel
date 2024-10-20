using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace ObserverSystem
{
    public class ObserverManager : MonoBehaviour
    {
        #region Singleton
        private static ObserverManager _instance = null;
        public static ObserverManager Instance => _instance;

        #endregion
        private List<Subject> _subject = null;
        private void Awake()
        {
            _instance = this;
        }
        #region Register Subject
        public void RegisterSubject(Subject subject)
        {
            if (_subject == null)
            {
                _subject = new List<Subject>();
            }
            _subject.Add(subject);
        }
        #endregion
        #region Register Observer
        public void RegisterObserver(Observer observer, SubjectType subjectType)
        {
            StartCoroutine(RegisterObserverDelay(observer, subjectType));
        }
        IEnumerator RegisterObserverDelay(Observer observer, SubjectType subjectType)
        {
            yield return null;
            foreach (var subject in _subject)
            {
                if (subject.SubjectType == subjectType)
                {
                    subject.RegisterObserver(observer);
                }
            }
        }
        #endregion
        #region Remove Subject
        public void RemoveSubject(Subject subject)
        {
            if (_subject.Count > 0)
            {
                _subject.Remove(subject);
            }
        }
        #endregion
        #region Remove Observer
        public void RemoveObserver(Observer observer)
        {
            foreach (var subject in _subject)
            {
                subject.RemoveObserver(observer);
            }
        }
        #endregion
    }
    public enum NotificationType
    {
        Win,
        Fail,
        Start,
        End
    }
    public enum SubjectType
    {
        GameState
    }
}