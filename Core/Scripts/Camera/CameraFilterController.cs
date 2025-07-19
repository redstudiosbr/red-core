using UnityEngine;
using UnityEngine.SceneManagement;

namespace RedStudios.Core.Camera
{
    /// <summary>
    /// Attach this component to a Camera to apply a generic post-processing filter (material).
    /// The camera GameObject will persist across scene loads, preserving the filter.
    /// </summary>
    [RequireComponent(typeof(UnityEngine.Camera))]
    public class CameraFilterController : MonoBehaviour
    {
        [Tooltip("Material containing the shader for the filter to be applied.")]
        [SerializeField] private Material _filterMaterial;

        /// <summary>
        /// Called after the scene has been rendered. Blits the source RenderTexture
        /// to the destination using the specified filter material.
        /// </summary>
        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (_filterMaterial != null)
                Graphics.Blit(src, dest, _filterMaterial);
            else
                Graphics.Blit(src, dest);
        }
    }
}
