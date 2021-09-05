diff --git a/config/core/configmaps/autoscaler.yaml b/config/core/configmaps/autoscaler.yaml
index e35e8ee6e..a17b2dd59 100644
--- a/config/core/configmaps/autoscaler.yaml
+++ b/config/core/configmaps/autoscaler.yaml
@@ -99,7 +99,7 @@ data:
     # When operating in a stable mode, the autoscaler operates on the
     # average concurrency over the stable window.
     # Stable window must be in whole seconds.
-    stable-window: "60s"
+    stable-window: "2s"
 
     # When observed average concurrency during the panic window reaches
     # panic-threshold-percentage the target concurrency, the autoscaler
diff --git a/pkg/apis/networking/register.go b/pkg/apis/networking/register.go
index 55a5fe66a..ceabdad29 100644
--- a/pkg/apis/networking/register.go
+++ b/pkg/apis/networking/register.go
@@ -107,5 +107,5 @@ const (
 // Pseudo-constants
 var (
 	// DefaultRetryCount will be set if Attempts not specified.
-	DefaultRetryCount = 3
+	DefaultRetryCount = 0
 )
diff --git a/pkg/autoscaler/scaling/autoscaler.go b/pkg/autoscaler/scaling/autoscaler.go
index 36cb665b5..4b7c10556 100644
--- a/pkg/autoscaler/scaling/autoscaler.go
+++ b/pkg/autoscaler/scaling/autoscaler.go
@@ -19,6 +19,7 @@ package scaling
 import (
 	"context"
 	"errors"
+	"fmt"
 	"math"
 	"sync"
 	"time"
@@ -263,7 +264,7 @@ func (a *Autoscaler) Scale(ctx context.Context, now time.Time) ScaleResult {
 
 	pkgmetrics.RecordBatch(a.reporterCtx, excessBurstCapacityM.M(excessBCF),
 		desiredPodCountM.M(int64(desiredPodCount)))
-
+	fmt.Println("VLOG: autoscaler:", spec.ServiceName, readyPodsCount, desiredPodCount)
 	return ScaleResult{
 		DesiredPodCount:     desiredPodCount,
 		ExcessBurstCapacity: int32(excessBCF),
