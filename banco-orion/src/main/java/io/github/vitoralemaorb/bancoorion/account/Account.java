package io.github.vitoralemaorb.bancoorion.account;

import io.github.vitoralemaorb.bancoorion.customer.Customer;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "account")
public class Account {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id")
    private Customer customer;

    private String branch;
    private String number;

    @Enumerated(EnumType.STRING)
    private AccountType type;

    private BigDecimal balance;
    private String currency;

    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;

    protected Account() {
    }

    public Account(Customer customer, String branch, String number, AccountType type, String currency) {
        this.customer = customer;
        this.branch = branch;
        this.number = number;
        this.type = type;
        this.currency = currency;
        this.balance = BigDecimal.ZERO;
    }

    public UUID getId() {
        return id;
    }

    public Customer getCustomer() {
        return customer;
    }

    public String getBranch() {
        return branch;
    }

    public String getNumber() {
        return number;
    }

    public AccountType getType() {
        return type;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public String getCurrency() {
        return currency;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
