USE simple_admin;
UPDATE fa_wanlshop_merchant SET password='333cb042f8bbb18037919adc325b3d7c', salt='a1b2c3' WHERE id=1;
UPDATE fa_wanlshop_shop_staff SET password='47d4d4e0ac128370d1da06e5de286a5f', salt='d4e5f6' WHERE id=1;
SELECT id, username, password, salt FROM fa_wanlshop_merchant;
SELECT id, nickname, password, salt FROM fa_wanlshop_shop_staff;
