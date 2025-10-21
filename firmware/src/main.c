#include <stddef.h>
#include <stdint.h>

#define LCD_DATA (*(volatile uint8_t *)0x8000'0000)
#define LCD_OPTS (*(volatile uint8_t *)0x8000'0001)
#define LCD_ENABLE (*(volatile uint8_t *)0x8000'0002)

static void lcd_send(uint8_t data) {
  LCD_DATA = data;
  LCD_ENABLE = 1;
  LCD_ENABLE = 0;
}

static void lcd_print(const char *s) {
  while (*s != '\0')
    lcd_send(*s++);
}

void start(void) {
  LCD_OPTS = 0b00; // Write instruction

  lcd_send(0b0000'0001); // Clear display
  lcd_send(0b0000'0010); // Reset cursor
  lcd_send(0b0000'1111); // Set cursor properties

  LCD_OPTS = 0b10; // Write data

  lcd_print("Hello, world!");
}
