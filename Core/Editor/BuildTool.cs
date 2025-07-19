using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;

namespace RedStudios.Core.Editor
{
    /// <summary>
    /// Enums representing supported build targets.
    /// </summary>
    public enum TargetDevice
    {
        Windows,
        Linux,
        MacOS,
        Android,
        iOS,
        PC,      // Windows + MacOS + Linux
        Mobile,  // Android + iOS
        Web      // WebGL
    }

    public static class BuildTool
    {
        private static readonly string[] Scenes =
            EditorBuildSettings.scenes
                .Where(s => s.enabled)
                .Select(s => s.path)
                .ToArray();

        private static string ProjectRoot => Path.GetFullPath(Path.Combine(Application.dataPath, ".."));

        [MenuItem("Red Studios/Build/Build for Windows", false, 10)]
        public static void BuildWindows() => Build(TargetDevice.Windows);

        [MenuItem("Red Studios/Build/Build for Linux", false, 11)]
        public static void BuildLinux() => Build(TargetDevice.Linux);

        [MenuItem("Red Studios/Build/Build for MacOS", false, 12)]
        public static void BuildMacOS() => Build(TargetDevice.MacOS);

        [MenuItem("Red Studios/Build/Build for Android", false, 14)]
        public static void BuildAndroid() => Build(TargetDevice.Android);

        [MenuItem("Red Studios/Build/Build for iOS", false, 15)]
        public static void BuildiOS() => Build(TargetDevice.iOS);

        [MenuItem("Red Studios/Build/Build for PC", false, 17)]
        public static void BuildPC() => Build(TargetDevice.PC);

        [MenuItem("Red Studios/Build/Build for Mobile", false, 18)]
        public static void BuildMobile() => Build(TargetDevice.Mobile);

        [MenuItem("Red Studios/Build/Build for Web", false, 19)]
        public static void BuildWeb() => Build(TargetDevice.Web);

        private static void Build(TargetDevice targetType)
        {
            // For desktop builds (Windows, Linux, MacOS, or PC), ask if this is a Steam build
            if (targetType == TargetDevice.Windows ||
                targetType == TargetDevice.Linux ||
                targetType == TargetDevice.MacOS ||
                targetType == TargetDevice.PC)
            {
                bool isSteam = EditorUtility.DisplayDialog(
                    "Steam Build?",
                    "Do you want to generate this build as a Steam version?",
                    "Yes",
                    "No"
                );

                // Add or remove the STEAM_BUILD scripting define
                var namedTarget = NamedBuildTarget.Standalone;
                string defines = PlayerSettings.GetScriptingDefineSymbols(namedTarget);
                var defineList = defines.Split(';').Where(s => !string.IsNullOrEmpty(s)).ToList();

                if (isSteam)
                {
                    if (!defineList.Contains("STEAM_BUILD"))
                        defineList.Add("STEAM_BUILD");
                }
                else
                {
                    defineList.RemoveAll(s => s == "STEAM_BUILD");
                }

                PlayerSettings.SetScriptingDefineSymbols(namedTarget, string.Join(";", defineList));
            }

            // Determine build groups, targets, and output folder
            BuildTargetGroup[] groups;
            BuildTarget[] targets;
            string folderName;

            switch (targetType)
            {
                case TargetDevice.Windows:
                    groups = new[] { BuildTargetGroup.Standalone };
                    targets = new[] { BuildTarget.StandaloneWindows64 };
                    folderName = "Windows";
                    break;
                case TargetDevice.Linux:
                    groups = new[] { BuildTargetGroup.Standalone };
                    targets = new[] { BuildTarget.StandaloneLinux64 };
                    folderName = "Linux";
                    break;
                case TargetDevice.MacOS:
                    groups = new[] { BuildTargetGroup.Standalone };
                    targets = new[] { BuildTarget.StandaloneOSX };
                    folderName = "MacOS";
                    break;
                case TargetDevice.Android:
                    groups = new[] { BuildTargetGroup.Android };
                    targets = new[] { BuildTarget.Android };
                    folderName = "Android";
                    break;
                case TargetDevice.iOS:
                    groups = new[] { BuildTargetGroup.iOS };
                    targets = new[] { BuildTarget.iOS };
                    folderName = "iOS";
                    break;
                case TargetDevice.PC:
                    groups = new[] { BuildTargetGroup.Standalone };
                    targets = new[] { BuildTarget.StandaloneWindows64, BuildTarget.StandaloneOSX, BuildTarget.StandaloneLinux64 };
                    folderName = "PC";
                    break;
                case TargetDevice.Mobile:
                    groups = new[] { BuildTargetGroup.Android, BuildTargetGroup.iOS };
                    targets = new[] { BuildTarget.Android, BuildTarget.iOS };
                    folderName = "Mobile";
                    break;
                case TargetDevice.Web:
                    groups = new[] { BuildTargetGroup.WebGL };
                    targets = new[] { BuildTarget.WebGL };
                    folderName = "Web";
                    break;
                default:
                    Debug.LogError($"Unsupported build target: {targetType}");
                    return;
            }

            // Create the output directory
            string outputRoot = Path.Combine(ProjectRoot, "Build", folderName);
            Directory.CreateDirectory(outputRoot);

            // Execute build for each target
            foreach (var buildTarget in targets)
            {
                EditorUserBuildSettings.SwitchActiveBuildTarget(groups[0], buildTarget);
                string exeName = Path.GetFileNameWithoutExtension(Application.productName);
                string outputPath = buildTarget switch
                {
                    BuildTarget.StandaloneWindows64 => Path.Combine(outputRoot, exeName + ".exe"),
                    BuildTarget.StandaloneOSX => Path.Combine(outputRoot, exeName + ".app"),
                    BuildTarget.Android => Path.Combine(outputRoot, exeName + ".apk"),
                    BuildTarget.iOS => outputRoot, // Xcode project folder
                    BuildTarget.WebGL => outputRoot, // WebGL folder
                    BuildTarget.StandaloneLinux64 => Path.Combine(outputRoot, exeName),
                    _ => Path.Combine(outputRoot, exeName)
                };

                var report = BuildPipeline.BuildPlayer(Scenes, outputPath, buildTarget, BuildOptions.None);
                if (report.summary.result == BuildResult.Succeeded)
                    Debug.Log($"[{targetType}] Build succeeded: {outputPath}");
                else
                    Debug.LogError($"[{targetType}] Build failed: {report.summary}");
            }

            AssetDatabase.Refresh();
        }
    }
}
