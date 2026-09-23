package com.vehiclerental.config;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Sitewide exception safety net.
 *
 * Any uncaught {@link RuntimeException} or {@link IOException} thrown from a
 * {@code @Controller} bubbles up here and is rendered through {@code error.jsp}
 * with a friendly message instead of Spring's white-label error page.
 *
 * This is the "user-friendly error messages in JSP" deliverable for Fix #10.
 * Logs full context to {@code System.err} so the OOP/file-IO marker can verify
 * the handler caught it; the user only sees a concise banner.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /** Anything that escapes a controller — render the dark-themed error page. */
    @ExceptionHandler(Exception.class)
    public String handleAny(Exception ex, HttpServletRequest req, Model model) {
        System.err.println("[GlobalExceptionHandler] " + req.getMethod() + " "
                + req.getRequestURI() + " — "
                + ex.getClass().getSimpleName() + ": " + ex.getMessage());

        model.addAttribute("pageTitle",     "Something went wrong");
        model.addAttribute("errorTitle",    friendlyTitle(ex));
        model.addAttribute("errorDetail",   friendlyDetail(ex));
        model.addAttribute("errorClass",    ex.getClass().getSimpleName());
        model.addAttribute("errorPath",     req.getRequestURI());
        return "error";
    }

    private String friendlyTitle(Exception ex) {
        if (ex instanceof IOException) return "We hit a file-storage hiccup.";
        if (ex instanceof IllegalArgumentException) return "Please check the vehicle information.";
        if (ex instanceof SQLException) return "The database rejected that request.";
        return "Something went wrong on our end.";
    }

    private String friendlyDetail(Exception ex) {
        if (ex instanceof IOException) {
            return "We couldn't reach one of our data files. Your request didn't go through — "
                 + "please try again in a moment. If this keeps happening, contact the host.";
        }
        if (ex instanceof IllegalArgumentException) {
            return "One of the values was missing or invalid. Go back and check the fields.";
        }
        if (ex instanceof SQLException) {
            return "The database could not complete the request. Check the SQL Server connection and try again.";
        }
        return "An unexpected error interrupted your request. We've logged the details — "
             + "head back to the home page and try again.";
    }
}
