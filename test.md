## ⚙️ 2. Thành phần cốt lõi cần hiểu

| Thành phần       | Ý nghĩa cơ bản                       | So sánh dễ hiểu                      |
|------------------|--------------------------------------|--------------------------------------|
| Pod              | Container hoặc nhóm container        | "Hộp chứa Docker"                    |
| Deployment       | Triển khai nhiều Pod, cập nhật version | "Bản phát hành có quản lý"         |
| Service          | LoadBalancer/ClusterIP cho các Pod   | "Router gắn nhãn"                   |
| ConfigMap/Secret | Lưu cấu hình ngoài app               | `.env` hoặc file cấu hình           |
| Ingress          | HTTP routing từ bên ngoài            | "Nginx reverse proxy nâng cấp"      |
| Volume           | Dữ liệu persist                      | "Ổ cứng gắn thêm cho container"     |

---

## 🛠 3. Bạn cần làm được gì để chạy được app Open Source (như OpenIM)

✅ **Biết chuyển file `docker-compose.yml` → thành các YAML tương đương**  
→ Dùng tool như [`kompose`](https://kompose.io/) hoặc viết tay.  
→ Biết dịch mỗi service trong `docker-compose` thành `Deployment`, `Service`, `ConfigMap`.

✅ **Hiểu cách expose app:**  
App trong K8s không lộ port ra ngoài — bạn phải dùng `Service` (type `NodePort`, `LoadBalancer`) hoặc `Ingress Controller`.

✅ **Biết dùng `kubectl` để quan sát:**
```bash
kubectl get pods
kubectl describe pod <tên>
kubectl logs <pod>
kubectl port-forward <pod> <local-port>:<container-port>

Chủ đề	Ý nghĩa
🔁 ConfigMap & Secrets	Tách config khỏi code (env vars, bí mật)
📈 Liveness & Readiness Probe	Tự động restart khi app lỗi
🔄 Horizontal Pod Autoscaler	Scale app theo CPU
📦 Ingress	Truy cập qua domain thay vì NodePort
📁 Helm	Template hóa YAML dễ quản lý