package com.vehiclerental.config;

import com.vehiclerental.booking.BookingServlet;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    /**
     * Register the C02 BookingServlet at /booking.
     * We use ServletRegistrationBean (NOT @WebServlet) to avoid clashing
     * with Spring Boot 3.x's route resolver.
     */
    @Bean
    public ServletRegistrationBean<BookingServlet> bookingServlet() {
        ServletRegistrationBean<BookingServlet> bean =
                new ServletRegistrationBean<>(new BookingServlet(), "/booking");
        bean.setLoadOnStartup(1);
        return bean;
    }
}
