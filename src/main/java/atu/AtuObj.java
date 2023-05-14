package atu;

import java.util.HashSet;
import java.util.Objects;
import java.util.UUID;

public class AtuObj {
    private String name, parent;
    private final UUID thisUUID;

    public AtuObj(String name) {
        this.name = name;
        thisUUID = UUID.randomUUID();
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getParent() {
        return parent;
    }

    public void setParent(String parent) {
        this.parent = parent;
    }

    public UUID getThisUUID() {
        return thisUUID;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        AtuObj other = (AtuObj) obj;
        return Objects.equals(name, other.name);
    }

    @Override
    public String toString() {
        return "AtuObj{" +
                "name='" + name + '\'' +
                ", parent='" + parent + '\'' +
                '}';
    }
}
