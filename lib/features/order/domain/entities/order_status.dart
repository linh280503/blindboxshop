/// Domain enum for order status
enum OrderStatus {
  pending, // Chờ xác nhận
  confirmed, // Đã xác nhận
  preparing, // Đang chuẩn bị
  shipping, // Đang giao hàng
  delivered, // Đã giao hàng
  completed, // Hoàn thành
  cancelled, // Đã hủy
  returned, // Đã trả hàng
}
