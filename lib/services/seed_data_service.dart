import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint thay cho print
import '../models/book_model.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- CẤU HÌNH SERVER XAMPP ---
  // Nếu IP máy bạn đổi, nhớ cập nhật lại số này
  final String _baseUrl = "http://192.168.1.130/tram_doc_data";

  // Danh sách dữ liệu sách (Đã khớp với file trong máy bạn)
  final List<Map<String, String>> _bookData = [
    {"title": "7 Thói Quen Để Thành Đạt", "author": "Stephen R. Covey", "type": "Kỹ năng", "file": "7_thoi_quen_de_thanh_dat.pdf"},
    {"title": "21 Bài Học Cho Thế Kỷ 21", "author": "Yuval Noah Harari", "type": "Khoa học", "file": "21_Bai_hoc_cho_the_ky_21.pdf"},
    {"title": "1001 Cách Giữ Chân Khách Hàng", "author": "Nhiều tác giả", "type": "Kinh doanh", "file": "1001_cach_giu_chan_khach_hang.pdf"},
    {"title": "Ác Và Trừng Phạt", "author": "Fyodor Dostoevsky", "type": "Văn học", "file": "ac_va_trung_phat.pdf"},
    {"title": "Bạn Thật Sự Có Tài", "author": "Mona Lisa Schulz", "type": "Kỹ năng", "file": "ban_that_su_co_tai.pdf"},
    {"title": "Bắt Trẻ Đồng Xanh", "author": "J.D. Salinger", "type": "Văn học", "file": "bat_tre_dong_xanh.pdf"},
    {"title": "Bí Mật Tư Duy Triệu Phú", "author": "T. Harv Eker", "type": "Kinh tế", "file": "bi_mat_tu_duy_trieu_phu.pdf"},
    {"title": "Biết Hài Lòng", "author": "Leo Babauta", "type": "Tâm lý", "file": "biet_hai_long.pdf"},
    {"title": "Bố Già", "author": "Mario Puzo", "type": "Tiểu thuyết", "file": "bo_gia.pdf"},
    {"title": "Cùng Con Trưởng Thành", "author": "E. Perry Good", "type": "Gia đình", "file": "cung_con_truong_thanh.pdf"},
    {"title": "Cha Giàu Cha Nghèo", "author": "Robert Kiyosaki", "type": "Kinh tế", "file": "cha_giau_cha_ngheo.pdf"},
    {"title": "Chờ Khế Nhận Vàng", "author": "Nhiều tác giả", "type": "Truyện ngắn", "file": "cho_khe_nhan_vang.pdf"},
    {"title": "Cuộc Đời Của Pi", "author": "Yann Martel", "type": "Phiêu lưu", "file": "cuoc_doi_cua_pi.pdf"},
    {"title": "Cuốn Theo Chiều Gió", "author": "Margaret Mitchell", "type": "Kinh điển", "file": "cuon_theo_chieu_gio.pdf"},
    {"title": "Đắc Nhân Tâm", "author": "Dale Carnegie", "type": "Kỹ năng", "file": "dac_nhan_tam.pdf"},
    {"title": "Dám Bị Ghét", "author": "Kishimi Ichiro", "type": "Tâm lý", "file": "dam_bi_ghet.pdf"},
    {"title": "Dám Nghĩ Lớn", "author": "David J. Schwartz", "type": "Kỹ năng", "file": "dam_nghi_lon.pdf"},
    {"title": "Dám Ước Mơ", "author": "Florence Littauer", "type": "Kỹ năng", "file": "dam_uoc_mo.pdf"},
    {"title": "Đánh Thức Năng Lực Vô Hạn", "author": "Anthony Robbins", "type": "Kỹ năng", "file": "danh_thuc_nang_luc_vo_han.pdf"},
    {"title": "Đất Rừng Phương Nam", "author": "Đoàn Giỏi", "type": "Văn học", "file": "dat_rung_phuong_nam.pdf"},
    {"title": "Dạy Con Làm Giàu (Tập 1)", "author": "Robert Kiyosaki", "type": "Kinh tế", "file": "day_con_lam_giau_tap_1.pdf"},
    {"title": "Dế Mèn Phiêu Lưu Ký", "author": "Tô Hoài", "type": "Thiếu nhi", "file": "de_men_phieu_luu_ky.pdf"},
    {"title": "Để Xây Dựng Doanh Nghiệp Hiệu Quả", "author": "Michael E. Gerber", "type": "Kinh doanh", "file": "de_xay_dung_doanh_nghiep_hieu_qua.pdf"},
    {"title": "Đời Đơn Giản Khi Ta Đơn Giản", "author": "Xuân Nguyễn", "type": "Tản văn", "file": "doi_don_gian_khi_ta_don_gian.pdf"},
    {"title": "Đời Ngắn Đừng Ngủ Dài", "author": "Robin Sharma", "type": "Kỹ năng", "file": "doi_ngan_dung_ngu_dai.pdf"},
    {"title": "Hạt Giống Tâm Hồn", "author": "Nhiều tác giả", "type": "Tâm hồn", "file": "hat_giong_tam_hon.pdf"},
    {"title": "Hoàng Tử Bé", "author": "Saint-Exupéry", "type": "Thiếu nhi", "file": "hoang_tu_be.pdf"},
    {"title": "Không Gia Đình", "author": "Hector Malot", "type": "Thiếu nhi", "file": "khong_gia_dinh.pdf"},
    {"title": "Kỹ Năng Đi Trước Đam Mê", "author": "Cal Newport", "type": "Sự nghiệp", "file": "ky-nang-di-truoc_dam_me.pdf"},
    {"title": "Làm Ít Được Nhiều", "author": "Leo Babauta", "type": "Kỹ năng", "file": "lam_it_duoc_nhieu.pdf"},
    {"title": "Nghệ Thuật Bán Hàng Bậc Cao", "author": "Zig Ziglar", "type": "Kinh doanh", "file": "nghe_thuat_ban_hang_bac_cao.pdf"},
    {"title": "Nghệ Thuật Đàm Phán", "author": "Donald Trump", "type": "Kinh doanh", "file": "nghe_thuat_dam_phan.pdf"},
    {"title": "Nghệ Thuật Lấy Lòng Khách Hàng", "author": "Michael LeBoeuf", "type": "Kinh doanh", "file": "nghe_thuat_lay_long_khach_hang.pdf"},
    {"title": "Nghĩ Lớn Để Thành Công", "author": "Donald Trump", "type": "Kinh doanh", "file": "nghi_lon_de_thanh_cong.pdf"},
    {"title": "Nhà Giả Kim", "author": "Paulo Coelho", "type": "Văn học", "file": "nha_gia_kim.pdf"},
    {"title": "Những Người Khốn Khổ", "author": "Victor Hugo", "type": "Kinh điển", "file": "nhung_nguoi_khon_kho.pdf"},
    {"title": "Những Tấm Lòng Cao Cả", "author": "Edmondo De Amicis", "type": "Giáo dục", "file": "nhung_tam_long_cao_ca.pdf"},
    {"title": "Nỗi Buồn Chiến Tranh", "author": "Bảo Ninh", "type": "Tiểu thuyết", "file": "noi_buon_chien_tranh.pdf"},
    {"title": "Ông Già Và Biển Cả", "author": "Ernest Hemingway", "type": "Văn học", "file": "ong_gia_va_bien_ca.pdf"},
    {"title": "Sinh Ra Để Chạy", "author": "Christopher McDougall", "type": "Thể thao", "file": "sinh_ra_de_chay.pdf"},
    {"title": "Sức Mạnh Của Thói Quen", "author": "Charles Duhigg", "type": "Tâm lý", "file": "suc_manh_cua_thoi_quen.pdf"},
    {"title": "Sức Mạnh Tiềm Thức", "author": "Joseph Murphy", "type": "Tâm linh", "file": "suc_manh_tiem_thuc.pdf"},
    {"title": "Tiền Không Mua Được Gì", "author": "Michael Sandel", "type": "Triết học", "file": "tien_khong_mua_duoc_gi.pdf"},
    {"title": "Tôi Đã Kiếm Được 2 Triệu Đô...", "author": "Nicolas Darvas", "type": "Đầu tư", "file": "toi_da_kiem_duoc_2_000_000_do_la_tu_thi_truong.pdf"},
    {"title": "Trăm Năm Cô Đơn", "author": "Gabriel Garcia Marquez", "type": "Văn học", "file": "tram_nam_co_don.pdf"},
    {"title": "Tư Duy Nhanh Và Chậm", "author": "Daniel Kahneman", "type": "Tâm lý", "file": "tu_duy_nhanh_va_cham.pdf"},
    {"title": "Tuần Làm Việc 4 Giờ", "author": "Timothy Ferriss", "type": "Kỹ năng", "file": "tuan_lam_viec_4_gio.pdf"},
    {"title": "Tuổi Trẻ Đáng Giá Bao Nhiêu", "author": "Rosie Nguyễn", "type": "Kỹ năng", "file": "tuoi_tre_dang_gia_bao_nhieu.pdf"},
    {"title": "Vợ Nhặt", "author": "Kim Lân", "type": "Văn học", "file": "vo_nhat.pdf"},
    {"title": "Yêu Những Điều Không Hoàn Hảo", "author": "Haemin", "type": "Tâm linh", "file": "yeu_nhung_dieu_khong_hoan_hao.pdf"},
  ];

  Future<void> seedSampleBooks() async {
    try {
      WriteBatch batch = _firestore.batch();
      debugPrint("🚀 Đang nạp ${_bookData.length} cuốn sách THẬT...");

      for (int i = 0; i < _bookData.length; i++) {
        final bookInfo = _bookData[i];
        DocumentReference docRef = _firestore.collection('books').doc();

        // Link ảnh bìa tự động
        String encodedTitle = Uri.encodeComponent(bookInfo["title"]!);
        String coverUrl = "https://ui-avatars.com/api/?name=$encodedTitle&background=random&color=fff&size=512&font-size=0.3&length=3";

        // Link PDF từ Server XAMPP
        String pdfUrl = "$_baseUrl/${bookInfo['file']}";

        final newBook = BookModel(
          id: docRef.id,
          title: bookInfo["title"]!,
          author: bookInfo["author"]!,
          imageUrl: coverUrl,
          description: "Cuốn sách '${bookInfo['title']}' là một tác phẩm nổi tiếng...",
          rating: 4.5,
          assetPath: pdfUrl,
          content: "Sách có file PDF.",

          // --- SỬA LỖI TẠI ĐÂY ---
          createdAt: DateTime.now(), // Thêm dòng này để fix lỗi 'createdAt' is required
          // isFavorite: false,      // Xóa dòng này để fix lỗi 'isFavorite' isn't defined
          // -----------------------
        );

        batch.set(docRef, newBook.toMap());
      }

      await batch.commit();
      debugPrint("✅ Đã nạp xong danh sách sách từ XAMPP!");

    } catch (e) {
      debugPrint("❌ Lỗi: $e");
    }
  }
}