package com.vehiclerental.db;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@Component
public class MssqlConnection {
    private final String url;
    private final String username;
    private final String password;

    public MssqlConnection(
            @Value("${ridelanka.db.url}") String url,
            @Value("${ridelanka.db.username}") String username,
            @Value("${ridelanka.db.password}") String password) {
        this.url = url;
        this.username = username;
        this.password = password;
    }

    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, username, password);
    }
}
