using UnityEngine;

public class RaycastClick : MonoBehaviour
{
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                Vector3 pos = hit.point;
                Debug.Log("Klick bei: " + pos);
                Application.ExternalEval($"logClick('scene1', {pos.x}, {pos.y}, {pos.z});");
            }
        }
    }
}
