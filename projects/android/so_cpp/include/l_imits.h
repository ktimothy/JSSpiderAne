#define TMP_MAX                 308915776
#endif /* __XPG_VISIBLE */

#include <sys/limits.h>

#if __POSIX_VISIBLE
#include <sys/syslimits.h>
#endif

#ifndef PAGESIZE
#define  PAGESIZE  PAGE_SIZE
#endif

#endif /* !_LIMITS_H_ */