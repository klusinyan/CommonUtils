#define GROUP_ID @"${project.groupId}"
#define ARTIFACT_ID @"${project.artifactId}"
#define VERSION @"${project.version}"
#define BUILD_NUMBER @"${svn.revision}${svn.specialStatus}"
#define LOG_VERSION NSLog(@"\n####################################\nGroupId    %@\nArtifactId %@\nVersion %@ (build %@)\n####################################", GROUP_ID, ARTIFACT_ID, VERSION, BUILD_NUMBER)