using UnityEngine;
using System.Runtime.InteropServices;

public class ClickSender : MonoBehaviour
{
#if UNITY_WEBGL && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern void SendClick(float x, float y, float z);
#endif

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                Vector3 pos = hit.point;
                Debug.Log("Geklickt bei: " + pos);

#if UNITY_WEBGL && !UNITY_EDITOR
                SendClick(pos.x, pos.y, pos.z);
#else
                Debug.Log($"Simulierter Klick an {pos} (nur Editor)");
#endif
            }
        }
    }
}
