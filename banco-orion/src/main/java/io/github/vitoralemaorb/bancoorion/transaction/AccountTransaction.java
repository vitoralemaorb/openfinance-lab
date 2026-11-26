package io.github.vitoralemaorb.bancoorion.transaction;

import io.github.vitoralemaorb.bancoorion.account.Account;
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

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "account_transaction")
public class AccountTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "account_id")
    private Account account;

    @Enumerated(EnumType.STRING)
    private TransactionType type;

    private BigDecimal amount;

    @Enumerated(EnumType.STRING)
    private TransactionCategory category;

    private String description;
    private Instant bookedAt;

    protected AccountTransaction() {
    }

    public AccountTransaction(Account account, TransactionType type, BigDecimal amount,
                              TransactionCategory category, String description, Instant bookedAt) {
        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException("O valor da transação deve ser maior que zero");
        }
        this.account = account;
        this.type = type;
        this.amount = amount;
        this.category = category;
        this.description = description;
        this.bookedAt = bookedAt;
    }

    public UUID getId() {
        return id;
    }

    public Account getAccount() {
        return account;
    }

    public TransactionType getType() {
        return type;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public TransactionCategory getCategory() {
        return category;
    }

    public String getDescription() {
        return description;
    }

    public Instant getBookedAt() {
        return bookedAt;
    }
}
